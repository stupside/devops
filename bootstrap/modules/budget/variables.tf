variable "compartment_id" {
  description = "The OCID of the compartment for the resources."
  type        = string
}

variable "budget_name" {
  description = "The name of the budget."
  type = string
  default = "k3s_budget"
}

variable "budget_amount" {
  description = "The amount of the budget for the resources."
  type        = number
}

variable "budget_amout_max" {
  description = "The maximum amount of the budget for the resources."
  type        = number
}
