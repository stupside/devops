resource "oci_core_vcn" "vcn" {
  cidr_blocks = [var.cidr]

  dns_label = var.dns_label
  display_name = var.dns_label

  compartment_id = var.compartment_id
}

resource "oci_core_internet_gateway" "internet_gateway" {
  vcn_id = oci_core_vcn.vcn.id

  compartment_id = oci_core_vcn.vcn.compartment_id

  display_name = "${oci_core_vcn.vcn.dns_label}-internet-gateway"
}

resource "oci_core_route_table" "route_table" {
  vcn_id = oci_core_vcn.vcn.id

  compartment_id = oci_core_vcn.vcn.compartment_id
  
  display_name = "${oci_core_vcn.vcn.dns_label}-route-table"

  route_rules {
    description = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}

resource "oci_core_subnet" "subnet" {
  availability_domain = var.availability_domain

  vcn_id = oci_core_vcn.vcn.id

  dns_label = oci_core_vcn.vcn.dns_label

  route_table_id = oci_core_route_table.route_table.id

  compartment_id = oci_core_vcn.vcn.compartment_id
  
  display_name = "${oci_core_vcn.vcn.dns_label}-subnet"

  cidr_block = cidrsubnet(oci_core_vcn.vcn.cidr_block, 8, 1)

  security_list_ids = [oci_core_security_list.sl.id]
}

resource "oci_core_security_list" "sl" {
  vcn_id = oci_core_vcn.vcn.id

  compartment_id = oci_core_vcn.vcn.compartment_id

  display_name = "${oci_core_vcn.vcn.dns_label}-sl"
}

resource "oci_load_balancer" "lb" {
  display_name = "${oci_core_vcn.vcn.dns_label}-lb"

  shape          = "10Mbps"
  compartment_id = oci_core_vcn.vcn.compartment_id

  subnet_ids = [oci_core_subnet.subnet.id]
}