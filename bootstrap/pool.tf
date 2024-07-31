resource "oci_identity_dynamic_group" "indentity_dynamic_group" {
  compartment_id = var.compartment_id

  name        = "${var.name}-identity-dynamic-group"
  description = "${var.name} identity dynamic group"

  matching_rule = "ALL {instance.compartment.id = '${var.compartment_id}'}"
}

resource "oci_core_instance_pool" "instance_pool_server" {
  display_name = "${var.name} server instance pool"

  instance_configuration_id = module.compute.instance_configuration_server_id

  compartment_id            = oci_identity_dynamic_group.indentity_dynamic_group.compartment_id

  depends_on = [oci_identity_dynamic_group.indentity_dynamic_group]

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [load_balancers]
  }

  placement_configurations {
    availability_domain = var.availability_domain

    primary_subnet_id = module.networking.networking_subnet_id
  }

  size = var.server_pool_size
}

resource "oci_core_instance_pool" "instance_pool_agent" {
  display_name = "${var.name} agent instance pool"

  instance_configuration_id = module.compute.instance_configuration_agent_id

  compartment_id            = oci_identity_dynamic_group.indentity_dynamic_group.compartment_id

  depends_on = [oci_identity_dynamic_group.indentity_dynamic_group]

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [load_balancers]
  }

  placement_configurations {
    availability_domain = var.availability_domain

    primary_subnet_id = module.networking.networking_subnet_id
  }

  size = var.agent_pool_size
}
