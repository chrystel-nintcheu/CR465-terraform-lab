output "vm_name" {
  value       = multipass_instance.lab.name
  description = "Name of the managed Multipass VM."
}

output "ipv4" {
  value       = multipass_instance.lab.ipv4
  description = "IPv4 address(es) assigned to the VM by Multipass."
}

output "lab_stage" {
  value       = var.lab_stage
  description = "Tutorial stage label encoded into the cloud-init provisioning."
}

output "db_vm_name" {
  value       = multipass_instance.db.name
  description = "Name of the secondary (DB) Multipass VM."
}

output "db_ipv4" {
  value       = multipass_instance.db.ipv4
  description = "IPv4 address(es) of the DB VM."
}
