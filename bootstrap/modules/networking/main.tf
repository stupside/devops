resource "oci_core_vcn" "vcn" {
  cidr_blocks = [var.cidr]

  dns_label = "${var.name}vcn"
  display_name = "${var.name} vcn"

  compartment_id = var.compartment_id
}

resource "oci_core_internet_gateway" "internet_gateway" {
  vcn_id = oci_core_vcn.vcn.id

  compartment_id = oci_core_vcn.vcn.compartment_id

  display_name = "${var.name}-internet-gateway"
}

resource "oci_core_route_table" "route_table" {
  vcn_id = oci_core_vcn.vcn.id

  compartment_id = oci_core_vcn.vcn.compartment_id
  
  display_name = "${var.name}-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    description       = "Route to Internet"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}

resource "oci_core_subnet" "subnet" {
  availability_domain = var.availability_domain

  vcn_id = oci_core_vcn.vcn.id

  dns_label = "${var.name}subnet"

  display_name = "${var.name} subnet"

  compartment_id = oci_core_vcn.vcn.compartment_id

  route_table_id = oci_core_route_table.route_table.id

  cidr_block = cidrsubnet(oci_core_vcn.vcn.cidr_block, 8, 1)

  security_list_ids = [oci_core_security_list.security_list.id]
}

resource "oci_core_security_list" "security_list" {
  vcn_id = oci_core_vcn.vcn.id

  compartment_id = oci_core_vcn.vcn.compartment_id

  display_name = "${var.name}-security-list"
}

resource "oci_load_balancer" "lb" {
  display_name = "${var.name}-load-balancer"

  shape          = "10Mbps"
  compartment_id = oci_core_vcn.vcn.compartment_id

  subnet_ids = [oci_core_subnet.subnet.id]
}