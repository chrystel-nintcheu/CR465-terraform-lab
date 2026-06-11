variable "vm_name" {
  description = "Name of the Multipass VM managed by the lab."
  type        = string
  default     = "cr465-lab"
}

variable "image" {
  description = "Multipass image alias to launch (e.g. lts, 24.04)."
  type        = string
  default     = "lts"
}

variable "cpus" {
  description = "Number of vCPUs assigned to the VM."
  type        = number
  default     = 2
}

variable "memory" {
  description = "Memory assigned to the VM as a Multipass size string (e.g. 2G)."
  type        = string
  default     = "2G"
}

variable "disk" {
  description = "Disk assigned to the VM as a Multipass size string (e.g. 10G)."
  type        = string
  default     = "10G"
}

variable "lab_stage" {
  description = "Tutorial stage label written into cloud-init."
  type        = string
  default     = "step-2-single-vm"
}
