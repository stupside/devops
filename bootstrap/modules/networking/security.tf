resource "oci_core_network_security_group" "network_security_group" {
  vcn_id = oci_core_vcn.vcn.id

  compartment_id = var.compartment_id

  display_name = "${var.name}-network-security-group"
}

resource "oci_core_network_security_group_security_rule" "http_in" {
  for_each = toset(["80", "443", "8080"])

  network_security_group_id = oci_core_network_security_group.network_security_group.id

  description = "Allow HTTP, HTTPS, and HTTP Alt traffic into the k3s security group"

  protocol  = 6
  direction = "INGRESS"

  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"

  destination      = "0.0.0.0/0"
  destination_type = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      min = each.key
      max = each.key
    }
  }
}

resource "oci_core_network_security_group_security_rule" "http_out" {
  for_each = toset(["80", "443", "8080"])

  network_security_group_id = oci_core_network_security_group.network_security_group.id

  description = "Allow HTTP, HTTPS, and HTTP Alt traffic out of the k3s security group"

  protocol  = 6
  direction = "EGRESS"

  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"

  destination      = "0.0.0.0/0"
  destination_type = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      min = each.key
      max = each.key
    }
  }
}
