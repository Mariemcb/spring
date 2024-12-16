variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The location of the resources"
  default     = "East US"
}

variable "owner" {
  description = "Owner of the script"
  default     = "tp-Terraform"
}

variable "jar_file_path" {
  description = "Path to the Spring Boot JAR file"
  type        = string
}
