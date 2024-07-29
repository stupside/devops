variable "compartment_id" {
  description = "The OCID of the compartment."
  type        = string
}

variable "server_shape" {
  description = "The shape for the server."
  type        = string
}

variable "server_shape_name" {
  description = "The name of the shape for servers."
  type = string
  default = "k3s_shape_server"
}

variable "server_shape_volume_gb" {
  description = "The size of the disk in gbs."
  type = string
}

variable "agent_shape" {
  description = "The shape for the agents."
  type        = string
}

variable "agent_shape_volume_gb" {
  description = "The size of the disk in gbs."
  type = string
}

variable "agent_shape_name" {
  description = "The name of the shape for agents."
  type = string
  default = "k3s_shape_agent"
}