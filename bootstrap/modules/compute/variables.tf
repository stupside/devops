variable "compartment_id" {
  description = "The OCID of the compartment."
  type        = string
}

variable "name" {
  description = "The name of the cluster."
}

variable "server_shape" {
  description = "The shape for the server."
  type        = string
}

variable "server_instance_volume" {
  description = "The size of the disk in gbs."
  type = string
}

variable "agent_shape" {
  description = "The shape for the agents."
  type        = string
}

variable "agent_instance_volume" {
  description = "The size of the disk in gbs."
  type = string
}