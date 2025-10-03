terraform {
  required_providers {
    esxi = {
      source = "registry.terraform.io/josenk/esxi"
    }
    local = {
      source = "hashicorp/local"
    }
  }
}

provider "esxi" {
  esxi_hostname = var.esxi_hostname
  esxi_hostport = var.esxi_hostport
  esxi_hostssl  = var.esxi_hostssl
  esxi_username = var.esxi_username
  esxi_password = var.esxi_password
}

resource "esxi_guest" "web-vm" {
  count      = 2
  guest_name = "web-${count.index + 1}"
  disk_store = var.disk_store
  memsize    = var.vm_memsize
  numvcpus   = var.vm_numvcpus

  ovf_source = var.ovf_source
  network_interfaces {
    virtual_network = var.virtual_network
  }

  guestinfo = {
    "metadata"          = filebase64("metadata.yml")
    "metadata.encoding" = "base64"
    "userdata"          = filebase64("userdata.yml")
    "userdata.encoding" = "base64"
  }
}

resource "esxi_guest" "db-vm" {
  guest_name = "db"
  disk_store = var.disk_store
  memsize    = var.vm_memsize
  numvcpus   = var.vm_numvcpus

  ovf_source = var.ovf_source
  network_interfaces {
    virtual_network = var.virtual_network
  }

  guestinfo = {
    "metadata"          = filebase64("metadata.yml")
    "metadata.encoding" = "base64"
    "userdata"          = filebase64("userdata.yml")
    "userdata.encoding" = "base64"
  }
}

# Genereer inventory
resource "local_file" "inventory" {
  content  = templatefile("${path.module}/inventory.ini.tpl", {
    web_vms = esxi_guest.web-vm
    db_vms = esxi_guest.db-vm
  })
  filename = "${path.module}/inventory.ini"

}