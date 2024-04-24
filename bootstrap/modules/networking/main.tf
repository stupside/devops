resource "oci_core_vcn" "k3s_vnc" {
  display_name = "k3s-vnc"

  compartment_id = var.compartment_id
}
