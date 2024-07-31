variable "compartment_id" {
  description = "The OCID of the compartment."
  type        = string
}

variable "server_shape" {
  description = "The shape for the server."
  type        = string
}

variable "server_instance_config_name" {
  description = "The name of the instance config for servers."
  type = string
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

variable "agent_instance_config_name" {
  description = "The name of the instance config for agents."
  type = string
}