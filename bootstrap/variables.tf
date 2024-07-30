variable "tenancy_ocid" {
  description = "The OCID of the tenancy."
  type        = string
}

variable "compartment_id" {
  description = "The OCID of the compartment."
  type        = string
}

variable "user_ocid" {
  description = "The OCID of the user."
  type = string
}

variable "fingerprint" {
  description = "The fingerpint."
  type = string
  sensitive = true
}

variable "private_key_path" {
  description = "The private key path."
  type = string
  sensitive = true
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
