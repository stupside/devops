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

variable "availability_domain" {
  description = "The availability domain to create resources in."
  type        = string
}

variable "dynamic_group_name" {
  description = "The name of the dynamic group."
  type = string
}

variable "server_pool_name" {
  description = "The name of the servers pool."
  type = string
}

variable "agent_pool_name" {
  description = "The name of the agents pool."
  type = string
}

variable "agent_pool_size" {
  description = "The number of agents in the k3s pool."
  default     = 2
  type        = number
}
