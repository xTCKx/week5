terraform {
    backend "remote" {
    organization = "terraform-organisatie"
    workspaces {
      name = "workspace"
    }
  }

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

resource "esxi_guest" "web" {
  guest_name = "web"
  disk_store = var.disk_store
  memsize    = var.vm_memsize
  numvcpus   = var.vm_numvcpus

  ovf_source = var.ovf_source
  network_interfaces {
    virtual_network = var.virtual_network
  }

  guestinfo = {
    "metadata"          = filebase64("${path.module}/../cloudinit/metadata.yml")
    "metadata.encoding" = "base64"
    "userdata"          = filebase64("${path.module}/../cloudinit/userdata.yml")
    "userdata.encoding" = "base64"
  }
}


# Genereer inventory
resource "local_file" "inventory" {
  content = templatefile("${path.module}/inventory.ini.tpl", {
    web_vms = esxi_guest.web
  })
  filename = "${path.module}/../ansible/inventory.ini"

}