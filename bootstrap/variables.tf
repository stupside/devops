variable "tenancy_ocid" {
  description = "The OCID of the tenancy."
  type        = string
}

variable "compartment_ocid" {
  description = "The OCID of the compartment."
  type        = string
}

variable "private_key" {
  description = "The private key used for authentication."
  type        = string
}

variable "availability_domain" {
  description = "The availability domain to create resources in."
  type        = string
  default = "3"
}

variable "dynamic_group_name" {
  description = "The name of the dynamic group."
  type = string
  default = "k3s_dyng"
}

variable "server_pool_name" {
  description = "The name of the servers pool."
  type = string
  default = "k3s_server_pool"
}

variable "agent_pool_name" {
  description = "The name of the agents pool."
  type = string
  default = "k3s_agent_pool"
}

variable "agent_pool_size" {
  description = "The number of agents in the k3s pool."
  type        = number
  default     = 2
}
