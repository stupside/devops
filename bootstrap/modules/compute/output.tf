output "k3s_server_instance_configuration_id" {
  value = oci_core_instance_configuration.k3s_server.id
}

output "k3s_agent_instance_configuration_id" {
  value = oci_core_instance_configuration.k3s_agent.id
}
