provider "oci" {
  region           = var.region
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path

  user_ocid    = var.user_ocid
  tenancy_ocid = var.tenancy_ocid
}

resource "oci_identity_compartment" "k3s_compartment" {
  name           = "k3s"
  compartment_id = var.compartment_ocid
  description    = "Compartment for k3s resources"
}

resource "oci_budget_budget" "k3s_budget" {
  compartment_id = oci_identity_compartment.k3s_compartment.id

  display_name = "k3s-budget"

  amount = 0

  reset_period = "MONTHLY"
}

resource "oci_budget_alert_rule" "k3s_budget_alert" {
  budget_id = oci_budget_budget.k3s_budget.id

  threshold      = 1
  threshold_type = "ABSOLUTE"

  type = "FORECASTED"

  message = "Budget for k3s has been exceeded"
}

module "compute" {
  source = "./modules/compute"

  k3s_agent_shape  = "VM.Standard.A1.Flex"
  k3s_server_shape = "VM.Standard.E2.1.Micro"

  compartment_id = oci_identity_compartment.k3s_compartment.id
}

module "networking" {
  source = "./modules/networking"

  k3s_subnet_cidr = "192.168.0.0/16"

  compartment_id = oci_identity_compartment.k3s_compartment.id
}
