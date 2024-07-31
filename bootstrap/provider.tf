provider "oci" {
  user_ocid = var.user_ocid
  tenancy_ocid = var.tenancy_ocid

  fingerprint = var.fingerprint
  private_key_path = var.private_key_path
}

resource "oci_identity_compartment" "cmpt" {
  name           = "${var.name}-compartment"
  description    = "${var.name} compartment"

  compartment_id = var.compartment_id
}

module "compute" {
  source = "./modules/compute"

  name = var.name

  agent_instance_volume = "15"
  agent_shape  = "VM.Standard.A1.Flex"

  server_instance_volume = "15"
  server_shape = "VM.Standard.E2.1.Micro"

  compartment_id = oci_identity_compartment.cmpt.id
}

module "networking" {
  source = "./modules/networking"

  cidr = "10.0.0.0/16"

  name = var.name

  availability_domain = var.availability_domain

  compartment_id = oci_identity_compartment.cmpt.id
}
