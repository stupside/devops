output "networking_vcn_id" {
  value = oci_core_vcn.k3s_vnc.id
}

output "networking_subnet_id" {
  value = oci_core_subnet.k3s_subnet.id
}

output "networking_load_balancer_id" {
  value = oci_load_balancer.k3s_loadbalancer.id
}
