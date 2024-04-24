resource "oci_core_subnet" "k3s_subnet" {
  display_name = "k3s-subnet"

  compartment_id = var.compartment_id

  vcn_id = oci_core_vcn.k3s_vnc.id

  cidr_block = var.k3s_subnet_cidr

  route_table_id = oci_core_vcn.k3s_vnc.default_route_table_id
}

resource "oci_load_balancer" "k3s_loadbalancer" {
  display_name = "k3s-lb"

  shape          = "10Mbps"
  compartment_id = var.compartment_id

  subnet_ids = [oci_core_subnet.k3s_subnet.id]
}
