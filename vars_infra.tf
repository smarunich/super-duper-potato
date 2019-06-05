# This file contains various variables that affect the configuration of the deployed infrastructure
#

variable "vnet_cidr" {
  description = "Primary CIDR block for VPC"
  default     = "172.20.0.0/16"
}

variable "flavour_centos" {
  description = "AWS instance type for servers etc"
  default     = "Standard_F2s"
}

variable "flavour_avi" {
  description = "AWS instance type for Avi controllers"
  default     = "Standard_DS4_v2"
}

variable "flavour_master" {
  description = "AWS instance type for servers etc"
  default     = "Standard_D4s_v3"
}

variable "flavour_server" {
  description = "AWS instance type for servers etc"
  default     = "Standard_D2s_v3"
}

variable "vol_size_centos" {
  description = "Volume size for instances in G"
  default     = "30"
}

variable "vol_size_avi" {
  description = "Volume size for Avi controllers in G"
  default     = "64"
}

