variable "compartment_id" {
  description = "The OCID of the compartment."
  type        = string
}

variable "k3s_subnet_cidr" {
  description = "The CIDR block for the k3s subnet."
  type        = string
}
