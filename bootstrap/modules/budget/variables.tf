variable "compartment_id" {
  description = "The OCID of the compartment for the k3s resources"
  type        = string
}

variable "k3s_budget_amount" {
  description = "The amount of the budget for the k3s resources"
  type        = number
}

variable "k3s_budget_amout_max" {
  description = "The maximum amount of the budget for the k3s resources"
  type        = number
}
