output "networking_vcn_id" {
  value = oci_core_vcn.vcn.id
}

output "networking_subnet_id" {
  value = oci_core_subnet.subnet.id
}

output "networking_load_balancer_id" {
  value = oci_load_balancer.lb.id
}
