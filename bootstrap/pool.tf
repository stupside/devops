resource "oci_identity_dynamic_group" "dyng" {
  compartment_id = var.compartment_id

  name        = var.dynamic_group_name
  description = var.dynamic_group_name

  matching_rule = "ALL {instance.compartment.id = '${var.compartment_id}'}"
}

resource "oci_core_instance_pool" "server_ipool" {
  display_name = var.server_pool_name

  instance_configuration_id = module.compute.server_ic_id

  compartment_id            = oci_identity_dynamic_group.dyng.compartment_id

  size = 1

  depends_on = [oci_identity_dynamic_group.dyng]

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [load_balancers]
  }

  placement_configurations {
    availability_domain = var.availability_domain

    primary_subnet_id = module.networking.networking_subnet_id
  }
}

resource "oci_core_instance_pool" "agent_ipool" {
  display_name = var.server_pool_name

  instance_configuration_id = module.compute.agent_ic_id

  compartment_id            = oci_identity_dynamic_group.dyng.compartment_id

  depends_on = [oci_identity_dynamic_group.dyng]

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
