terraform {
  required_version  = ">= 0.13"

  required_providers {
    yandex = {
      source        = "yandex-cloud/yandex"
      version       = "0.119.0"
    }
  }
}

provider "yandex" {
  token             = var.token
  cloud_id          = var.cloud
  folder_id         = var.folder
}