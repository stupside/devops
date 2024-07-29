provider "oci" {
  private_key = var.private_key

  tenancy_ocid = var.tenancy_ocid
}

resource "oci_identity_compartment" "cmpt" {
  name           = "k3s_comprtment"
  description    = "Compartment for k3s resources"

  compartment_id = var.compartment_ocid
}

module "budget" {
  source = "./modules/budget"

  budget_amount    = 0
  budget_amout_max = 1

  compartment_id = oci_identity_compartment.cmpt.id
}

module "compute" {
  source = "./modules/compute"

  agent_shape_volume_gb = "15"
  agent_shape  = "VM.Standard.A1.Flex"

  server_shape_volume_gb = "15"
  server_shape = "VM.Standard.E2.1.Micro"

  compartment_id = oci_identity_compartment.cmpt.id
}

module "networking" {
  source = "./modules/networking"

  cidr = "10.0.0.0/16"
  availability_domain = "1"

  compartment_id = oci_identity_compartment.cmpt.id
}
