resource "oci_budget_budget" "k3s_budget" {
  compartment_id = var.compartment_id

  display_name = "k3s-budget"

  amount = var.k3s_budget_amount

  reset_period = "MONTHLY"
}

resource "oci_budget_alert_rule" "k3s_budget_alert" {
  budget_id = oci_budget_budget.k3s_budget.id

  threshold      = var.k3s_budget_amout_max
  threshold_type = "ABSOLUTE"

  type = "FORECASTED"

  message = "Budget for k3s has been exceeded"
}
