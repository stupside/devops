variable "tenancy_ocid" {
  description = "The OCID of the tenancy."
  type        = string
}

variable "compartment_ocid" {
  description = "The OCID of the compartment."
  type        = string
}

variable "user_ocid" {
  description = "The OCID of the user."
  type        = string
}

variable "region" {
  description = "The region to create resources in."
  type        = string
}

variable "fingerprint" {
  description = "The fingerprint of the public key used for authentication."
  type        = string
}

variable "private_key_path" {
  description = "The path to the private key used for authentication."
  type        = string
}

variable "k3s_availability_domain" {
  description = "The availability domain to create resources in."
  type        = string
}

variable "k3s_server_pool_size" {
  description = "The number of servers in the k3s pool."
  default     = 1
  type        = number
}

variable "k3s_agent_pool_size" {
  description = "The number of agents in the k3s pool."
  default     = 2
  type        = number
}
