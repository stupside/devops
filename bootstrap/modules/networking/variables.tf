variable "name" {
  description = "The name of the vcn."
  type = string
}

variable "compartment_id" {
  description = "The OCID of the compartment."
  type        = string
}

variable "cidr" {
  description = "The CIDR block for the cluster."
  type        = string
}

variable "availability_domain" {
  description = "The availability name of the subnet"
  type = string
}