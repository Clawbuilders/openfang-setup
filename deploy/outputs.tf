output "instance_public_ip" {
  description = "Public IP of the OpenFang instance (for SSH access only — port 4200 is Tailscale-only)."
  value       = oci_core_instance.openfang.public_ip
}

output "ssh_command" {
  description = "SSH command to connect to the instance."
  value       = "ssh opc@${oci_core_instance.openfang.public_ip}"
}

output "dashboard_url" {
  description = "OpenFang dashboard URL — accessible via Tailscale only. Run 'tailscale ip -4' on the instance to get the exact IP."
  value       = "http://<tailscale-ip>:4200  (run: tailscale ip -4 on the instance)"
}

output "check_status" {
  description = "Command to check whether OpenFang is running (run via SSH)."
  value       = "ssh opc@${oci_core_instance.openfang.public_ip} 'sudo docker compose -f /opt/openfang/deploy/docker-compose.oracle.yml ps'"
}
