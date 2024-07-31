provider "oci" {
  user_ocid = var.user_ocid
  tenancy_ocid = var.tenancy_ocid

  fingerprint = var.fingerprint
  private_key_path = var.private_key_path
}

resource "oci_identity_compartment" "cmpt" {
  name           = "${var.name}-compartment"
  description    = "Compartment for resources"

  compartment_id = var.compartment_id
}

module "compute" {
  source = "./modules/compute"

  agent_instance_volume = "15"
  agent_shape  = "VM.Standard.A1.Flex"
  agent_instance_name = "${var.name}-iconf-agent"

  server_instance_volume = "15"
  server_shape = "VM.Standard.E2.1.Micro"
  server_instance_name = "${var.name}-iconf-server"

  compartment_id = oci_identity_compartment.cmpt.id
}

module "networking" {
  source = "./modules/networking"

  cidr = "10.0.0.0/16"

  dns_label = "${var.name}-dns"

  availability_domain = var.availability_domain

  compartment_id = oci_identity_compartment.cmpt.id
}
