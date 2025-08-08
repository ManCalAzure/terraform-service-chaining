
variable "zedcloud_url" { type = string }

variable "zedcloud_token" { type = string }

variable "device_serial" { #-------Edge node serial
  type = string
  sensitive = true
  default = "<edge node soft_serial or hardwaer serial"
  }

variable "docker_hub_user" { #-------Docker Hub user
  type = string
  sensitive = true
  default = "zedmanny"
  }


variable "docker_hub_secret" { #-------Docker Hub secret
  type = string
  sensitive = true
  default = "net pass"
  }


variable "onboarding_key" { #-------Onboarding key (you can use this one)
  default = "5d0767ee-0547-4569-b530-387e526f8cb9"
  sensitive = true
}

#---------------Azure Blob 
variable "azure_blob_url" { #-------If you are using Azure blob to pull VM images
    description = "Azure blob URL"
    type        = string
    default     = "https://<blob name>.blob.core.windows.net"
}

variable "azure_blob_api_username" { #-------this info is in terraform.tfvars
    description = "API Key - or Username"
    type        = string
    sensitive   = true
}

variable "azure_blob_password" { #-------this info is in terraform.tfvars
    description = "This is the passkey for Azure blob"
    type        = string
    sensitive   = true

}

variable "azure_ds_path" { #------- Path to blob store
    description = "Path to blob"
    type        = string
    default     = "demo-blob" #------- Actual path
    sensitive = true
}

variable "datastore_type" {
    description = "Zededa datastore type"
    type        = string
    default     = "DATASTORE_TYPE_AZUREBLOB"
}

variable "ssh_pub_key" {
  default = "<ssh public key>"
  sensitive = true
}

variable "edgeview_token" {
  default = "<zededa edgeview token (same)>"
  sensitive = true
}