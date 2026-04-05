terraform {
  required_version = ">= 1.3"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0"
    }
  }
}

# ── Data sources ──────────────────────────────────────────────────────────────

# Oracle Linux 9 ARM64 (latest platform image in the region)
data "oci_core_images" "oracle_linux_9_arm64" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "9"
  shape                    = "VM.Standard.A1.Flex"
  state                    = "AVAILABLE"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# ── Networking ────────────────────────────────────────────────────────────────

resource "oci_core_vcn" "openfang" {
  compartment_id = var.compartment_ocid
  cidr_blocks    = ["10.0.0.0/16"]
  display_name   = "openfang-vcn"
  dns_label      = "openfang"
}

resource "oci_core_internet_gateway" "openfang" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.openfang.id
  display_name   = "openfang-igw"
  enabled        = true
}

resource "oci_core_route_table" "openfang" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.openfang.id
  display_name   = "openfang-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.openfang.id
  }
}

resource "oci_core_security_list" "openfang" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.openfang.id
  display_name   = "openfang-sl"

  # Allow all outbound (needed to pull Docker images, contact Tailscale, reach LLM APIs)
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  # Allow SSH from anywhere (restrict to your IP in production)
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }

  # Allow Tailscale UDP (WireGuard)
  ingress_security_rules {
    protocol = "17" # UDP
    source   = "0.0.0.0/0"
    udp_options {
      min = 41641
      max = 41641
    }
  }

  # Port 4200 is intentionally NOT opened here.
  # Access to OpenFang is via Tailscale only (100.x.x.x network).
  # The instance-level iptables rules (applied by cloud-init) also enforce this.
}

resource "oci_core_subnet" "openfang" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.openfang.id
  cidr_block        = "10.0.1.0/24"
  display_name      = "openfang-subnet"
  dns_label         = "openfangpub"
  route_table_id    = oci_core_route_table.openfang.id
  security_list_ids = [oci_core_security_list.openfang.id]
}

# ── Cloud-init user data ──────────────────────────────────────────────────────

locals {
  # Map provider name to env var name
  llm_env_var = {
    nvidia    = "NVIDIA_API_KEY"
    groq      = "GROQ_API_KEY"
    openai    = "OPENAI_API_KEY"
    anthropic = "ANTHROPIC_API_KEY"
  }

  # Map provider name to model string for openfang.toml
  llm_model = {
    nvidia    = "nvidia/llama-3.3-nemotron-super-49b-v1"
    groq      = "llama-3.3-70b-versatile"
    openai    = "gpt-4o-mini"
    anthropic = "claude-3-5-haiku-20241022"
  }

  # Map provider name to base_url (empty = driver default)
  llm_base_url = {
    nvidia    = "https://integrate.api.nvidia.com/v1"
    groq      = ""
    openai    = ""
    anthropic = ""
  }

  # Map provider name to driver name
  llm_driver = {
    nvidia    = "openai"
    groq      = "groq"
    openai    = "openai"
    anthropic = "anthropic"
  }

  cloud_init = templatefile("${path.module}/cloud_init.yaml.tpl", {
    tailscale_auth_key   = var.tailscale_auth_key
    llm_env_var          = local.llm_env_var[var.llm_provider]
    llm_api_key          = var.llm_api_key
    llm_driver           = local.llm_driver[var.llm_provider]
    llm_model            = local.llm_model[var.llm_provider]
    llm_base_url         = local.llm_base_url[var.llm_provider]
    openfang_api_key     = var.openfang_api_key
  })
}

# ── Compute instance (Always Free — Ampere A1) ────────────────────────────────

resource "oci_core_instance" "openfang" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = "openfang"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_memory_in_gbs
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.oracle_linux_9_arm64.images[0].id
    boot_volume_size_in_gbs = 50
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.openfang.id
    assign_public_ip = true
    display_name     = "openfang-vnic"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(local.cloud_init)
  }

  # Preserve the instance across plan changes (prevent accidental termination)
  lifecycle {
    ignore_changes = [metadata, source_details[0].source_id]
  }
}
