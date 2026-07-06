



variable "admin_username" {
  type        = string
  description = "The name of the admin of both computers"
  default     = "toby"

}




variable "admin_password" {
  type        = string
  description = "This is the password of the vm"
  sensitive   = true

}