variable "compartment_id" {
    description = "The OCID of the compartment."
    type = string
}

variable "k3s_server_shape" {
    description = "The shape for the k3s server."
    default = "VM.Standard.E2.1.Micro"
    type = string
}

variable "k3s_agent_shape" {
    description = "The shape for the k3s agent."
    default = "VM.Standard.A1.Flex"
    type = number
}