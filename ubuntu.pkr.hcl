variable "azure_image_version" {
  default = "1.0.5"
}

variable "azure_location" {
  default = "uksouth"
}

variable "azure_object_id" {
  default = ""
}

variable "resource_group_name" {
  default = "hmcts-image-gallery-rg"
}

variable "azure_storage_account" {
  default = ""
}

variable "subscription_id" {
  default = ""
}

variable "tenant_id" {
  default = ""
}

variable "ssh_user" {
  default = ""
}

variable "ssh_password" {
  default = ""
}

variable "image_name" {
  default = "bastion-ubuntu-v2"
}

variable "image_offer" {
  default = "ubuntu-24_04-lts"
}

variable "image_publisher" {
  default = "Canonical"
}

variable "image_sku" {
  default = "server"
}

variable "vm_size" {
  default = "Standard_D2ds_v5"
}

variable "client_secret" {
  default = ""
}

variable "client_id" {
  default = ""
}

source "azure-arm" "pr-azure-os-image" {
  azure_tags = {
    imagetype = var.image_name
    timestamp = formatdate("YYYYMMDDhhmmss", timestamp())
  }
  image_offer                       = var.image_offer
  image_publisher                   = var.image_publisher
  image_sku                         = var.image_sku
  location                          = var.azure_location
  managed_image_name                = "bastion-ubuntu-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  managed_image_resource_group_name = var.resource_group_name
  os_type                           = "Linux"
  ssh_pty                           = "true"
  ssh_username                      = var.ssh_user
  subscription_id                   = var.subscription_id
  tenant_id                         = var.tenant_id
  client_id                         = var.client_id
  client_secret                     = var.client_secret
  vm_size                           = var.vm_size

  shared_image_gallery_destination {
    subscription        = var.subscription_id
    resource_group      = var.resource_group_name
    gallery_name        = "hmcts"
    image_name          = var.image_name
    image_version       = var.azure_image_version
    replication_regions = ["UK South"]
  }

  shared_gallery_image_version_exclude_from_latest = true
}

source "azure-arm" "azure-os-image" {
  azure_tags = {
    imagetype = var.image_name
    timestamp = formatdate("YYYYMMDDhhmmss", timestamp())
  }
  image_offer                       = var.image_offer
  image_publisher                   = var.image_publisher
  image_sku                         = var.image_sku
  location                          = var.azure_location
  managed_image_name                = "bastion-ubuntu-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  managed_image_resource_group_name = var.resource_group_name
  os_type                           = "Linux"
  ssh_pty                           = "true"
  ssh_username                      = var.ssh_user
  subscription_id                   = var.subscription_id
  tenant_id                         = var.tenant_id
  client_id                         = var.client_id
  client_secret                     = var.client_secret
  vm_size                           = var.vm_size

  shared_image_gallery_destination {
    subscription        = var.subscription_id
    resource_group      = var.resource_group_name
    gallery_name        = "hmcts"
    image_name          = var.image_name
    image_version       = var.azure_image_version
    replication_regions = ["UK South"]
  }
}

build {
  sources = ["source.azure-arm.azure-os-image", "source.azure-arm.pr-azure-os-image"]

  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script          = "provision-bastion.sh"
  }

}
