variable "compartment_id" {
  description = "The OCID of the compartment."
  type        = string
}

variable "cidr" {
  description = "The CIDR block for the cluster."
  type        = string
}

variable "dns_label" {
  description = "The label for the dns."
  type = string
  default = "k3s_dns"
}

variable "security_group_name" {
  description = "The name of the security group."
  type = string
  default = "k3s_network_secg"
}

variable "availability_domain" {
  description = "The availability name of the subnet"
  type = string
}