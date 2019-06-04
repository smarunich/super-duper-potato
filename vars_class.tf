# This file contains various variables that affect the class itself
#

# The following variables should be defined via a seperate mechanism to avoid distribution
# For example the file terraform.tfvars

variable "azure_subscription_id" {
}

variable "azure_client_id" {
}

variable "azure_client_secret" {
}

variable "azure_tenant_id" {
}

variable "azure_avi_image_id" {
  default = "/subscriptions/77d6aa12-ef65-44f8-b9f5-07e7f7e8b48b/resourceGroups/avitraining/providers/Microsoft.Compute/images/controller1823"
}

variable "location" {
}

#variable "pkey" {
#}

variable "avi_default_password" {
}

variable "avi_admin_password" {
}

variable "avi_ssh_admin_username" {
  default = "aviadmin"
}

variable "avi_backup_admin_username" {
  default = "aviadmin"
}

variable "avi_backup_admin_password" {
}


variable "ocp_oreg_auth_user" {
}

variable "ocp_oreg_auth_password" {
}

variable "ocp_rhsm_pool_id" {
}

variable "student_count" {
  description = "The class size. Each student gets a controller"
  default     = 1
}

variable "lab_timezone" {
  description = "Lab Timezone: PST, EST, GMT or SGT"
}

variable "server_count" {
  description = "The class size. Students get a shared servers"
  default     = 3
}

variable "master_count" {
  description = "The class size. Students get a shared servers"
  default     = 1
}

variable "id" {
  description = "A prefix for the naming of the objects / instances"
  default     = "aviOCP"
}

variable "owner" {
  description = "Sets Owner tag appropriately"
  default     = "aviOCP_Training"
}

variable "ocp_rhsm_org" {
  description = "RedHat Subscription Manager Org"
  default = "avi_ocp"
}

variable "ocp_rhsm_activationkey" {
  description = "RedHat Subscription Manager OCP activation key"
  default = "avi_ocpkey"
}