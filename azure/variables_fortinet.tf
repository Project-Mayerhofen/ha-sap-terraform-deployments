variable "fortinet_enabled" {
  description = "Create FortiGate AP ELB/ILB and FortiADC HA deployments"
  type        = bool
  default     = false
}

variable "snet_ids" {
  description = "FortiGate AP ELB/ILB and FortiADC HA deployment subnet ids"
  type    = list(string)
  default = []
}

variable "snet_address_ranges" {
  description = "FortiGate AP ELB/ILB and FortiADC HA deployment subnet address ranges"
  type    = list(string)
  default = []
}

variable "fortinet_licenses" {
  description = "FortiGate AP ELB/ILB and FortiADC HA deployment license files"
  type = map
  default = {
    "license_a" = "license_a.lic"
    "license_b" = "license_b.lic"
  }
}

variable "fortinet_vm_publisher" {
  type = string
  default = "fortinet"
}

variable "fortinet_vm_license_type" {
  type = string
  default = "byol"
}

variable "fortigate_a_license_file"  {
  type = string
  default = "license_a.lic"
}

variable "fortigate_b_license_file"  {
  type = string
  default = "license_b.lic"
}

variable "fortigate_vm_offer"  {
  type = string
  default = "fortinet_fortigate-vm_v5"
}

variable "fortigate_vm_sku" {
  type = string
  default = "fortinet_fg-vm"
}

variable "fortigate_vm_size" {
  type = string
  default = "Standard_F4s"
}

variable "fortigate_vm_version" {
  type = string
  default = "7.0.1"
}

variable "fortigate_vm_username" {
  type = string
  default = "azureuser"
}

variable "fortigate_vm_password" {
  type = string
  default = "Password123!!"
}

variable "fortiadc_a_license_file"  {
  type = string
  default = "license_a.lic"
}

variable "fortiadc_b_license_file"  {
  type = string
  default = "license_b.lic"
}
variable "fortiadc_vm_offer"  {
  type = string
  default = "fortinet-fortiadc"
}

variable "fortiadc_vm_sku" {
  type = string
  default = "fad-vm-byol"
}

variable "fortiadc_vm_size" {
  type = string
  default = "Standard_F4s"
}

variable "fortiadc_vm_version" {
  type = string
  default = "6.1.3"
}

variable "fortiadc_vm_username" {
  type = string
  default = "azureuser"
}

variable "fortiadc_vm_password" {
  type = string
  default = "Password123!!"
}