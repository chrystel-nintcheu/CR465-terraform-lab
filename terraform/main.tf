provider "multipass" {
  command_timeout = 600
}

resource "multipass_instance" "lab" {
  name   = var.vm_name
  image  = var.image
  cpus   = var.cpus
  memory = var.memory
  disk   = var.disk

  cloud_init = templatefile("${path.module}/../cloud-init/user-data.yaml.tftpl", {
    hostname  = var.vm_name
    lab_stage = var.lab_stage
  })
}

resource "multipass_alias" "shell" {
  name     = "${var.vm_name}-shell"
  instance = multipass_instance.lab.name
  command  = "bash"
}

# ---------------------------------------------------------------------------
# Lab 05 -- File transfers
# ---------------------------------------------------------------------------
resource "multipass_file_upload" "lab_file" {
  instance    = multipass_instance.lab.name
  destination = "/tmp/lab-file.yaml"
  source      = "${path.module}/../cloud-init/user-data-fresh.yaml"
}

resource "multipass_file_download" "lab_ready" {
  instance       = multipass_instance.lab.name
  source         = "/var/tmp/cr465-lab-ready.txt"
  destination    = "${path.module}/../results/cr465-lab-ready.txt"
  create_parents = true
  overwrite      = true
  triggers = {
    instance_id = multipass_instance.lab.name
  }
}

# ---------------------------------------------------------------------------
# Lab 07 -- Multi-VM
# ---------------------------------------------------------------------------
resource "multipass_instance" "db" {
  name   = "${var.vm_name}-db"
  image  = var.image
  cpus   = 1
  memory = "1G"
  disk   = "5G"

  cloud_init = templatefile("${path.module}/../cloud-init/user-data.yaml.tftpl", {
    hostname  = "${var.vm_name}-db"
    lab_stage = "step-7-multi-vm-db"
  })

  depends_on = [multipass_instance.lab]
}
