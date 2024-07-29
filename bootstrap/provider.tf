provider "oci" {
  region           = var.region
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path

  user_ocid    = var.user_ocid
  tenancy_ocid = var.tenancy_ocid
}

resource "oci_identity_compartment" "cmpt" {
  name           = "k3s_comprtment"
  compartment_id = var.compartment_ocid
  description    = "Compartment for resources"
}

module "budget" {
  source = "./modules/budget"

  budget_name = "k3s_budget"

  budget_amount    = 0
  budget_amout_max = 1

  compartment_id = oci_identity_compartment.cmpt.id
}

module "compute" {
  source = "./modules/compute"

agent_shape_volume_gb = "15"
  agent_shape_name = "k3s_shape_agent"
  agent_shape  = "VM.Standard.A1.Flex"

  server_shape_volume_gb = "15"
  server_shape_name = "k3s_shape_server"
  server_shape = "VM.Standard.E2.1.Micro"

  compartment_id = oci_identity_compartment.cmpt.id
}

module "networking" {
  source = "./modules/networking"

  cidr = "10.0.0.0/16"

  dns_label = "k3s_dns"
  availability_domain = "1"
  security_group_name = "k3s_network_secg"

  compartment_id = oci_identity_compartment.cmpt.id
}
