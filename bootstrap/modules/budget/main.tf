resource "oci_budget_budget" "budget" {
  compartment_id = var.compartment_id

  display_name = var.budget_amount

  amount = var.budget_amount

  reset_period = "MONTHLY"
}

resource "oci_budget_alert_rule" "budget_alert" {
  budget_id = oci_budget_budget.budget.id

  threshold      = var.budget_amout_max
  threshold_type = "ABSOLUTE"

  type = "FORECASTED"

  message = "Budget has exceeded"
}
