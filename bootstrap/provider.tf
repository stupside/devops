provider "oci" {
    region           = var.region
    fingerprint      = var.fingerprint
    private_key_path = var.private_key_path

    user_ocid        = var.user_ocid
    tenancy_ocid     = var.tenancy_ocid
}

resource "oci_identity_compartment" "k3s_compartment" {
    name           = "k3s"
    compartment_id = var.compartment_ocid
}

module "compute" {
    source = "./compute"

    k3s_agent_shape = "VM.Standard.A1.Flex"
    k3s_server_shape = "VM.Standard.E2.1.Micro"
    
    compartment_id = oci_identity_compartment.k3s_compartment.id
}

module "network" {
    source = "./network"
}