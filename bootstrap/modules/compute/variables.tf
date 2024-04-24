variable "compartment_id" {
  description = "The OCID of the compartment."
  type        = string
}

variable "k3s_server_shape" {
  description = "The shape for the k3s server."
  type        = string
}

variable "k3s_agent_shape" {
  description = "The shape for the k3s agent."
  type        = string
}
