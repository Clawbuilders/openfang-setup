# ── Required ──────────────────────────────────────────────────────────────────

variable "tenancy_ocid" {
  description = "OCID of the tenancy. Auto-populated by Oracle Resource Manager."
  type        = string
}

variable "region" {
  description = "OCI region to deploy into. Auto-populated by Oracle Resource Manager."
  type        = string
}

variable "compartment_ocid" {
  description = "OCID of the compartment where resources will be created."
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for instance access. Paste the contents of your ~/.ssh/id_rsa.pub or similar."
  type        = string
  sensitive   = true
}

variable "tailscale_auth_key" {
  description = "Tailscale auth key (tskey-auth-...). Generate at https://login.tailscale.com/admin/settings/keys — use a reusable, ephemeral key tagged with tag:server."
  type        = string
  sensitive   = true
}

# ── LLM Provider ──────────────────────────────────────────────────────────────

variable "llm_provider" {
  description = "LLM provider to use as the default model backend."
  type        = string
  default     = "nvidia"
  validation {
    condition     = contains(["nvidia", "groq", "openai", "anthropic"], var.llm_provider)
    error_message = "Must be one of: nvidia, groq, openai, anthropic."
  }
}

variable "llm_api_key" {
  description = "API key for the selected LLM provider. NVIDIA: nvapi-... / Groq: gsk_... / OpenAI: sk-... / Anthropic: sk-ant-..."
  type        = string
  sensitive   = true
  default     = ""
}

variable "openfang_api_key" {
  description = "Bearer token to protect the OpenFang HTTP API (recommended). Leave empty to disable auth (tailnet-only access is still enforced)."
  type        = string
  sensitive   = true
  default     = ""
}

# ── Compute ───────────────────────────────────────────────────────────────────

variable "instance_ocpus" {
  description = "Number of OCPUs for the Ampere A1 instance (Always Free: up to 4 total across all A1 instances)."
  type        = number
  default     = 2
  validation {
    condition     = var.instance_ocpus >= 1 && var.instance_ocpus <= 4
    error_message = "Must be between 1 and 4."
  }
}

variable "instance_memory_in_gbs" {
  description = "RAM for the Ampere A1 instance in GB (Always Free: up to 24 GB total)."
  type        = number
  default     = 12
  validation {
    condition     = var.instance_memory_in_gbs >= 6 && var.instance_memory_in_gbs <= 24
    error_message = "Must be between 6 and 24."
  }
}
