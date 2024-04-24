resource "oci_identity_dynamic_group" "k3s_pool" {
    compartment_id = var.compartment_ocid

    name           = "k3s-pool"
    description    = "Dynamic group for k3s pool"

    matching_rule = "ALL {instance.compartment.id = '${var.compartment_ocid}'}"
}

resource "oci_core_instance_pool" "k3s_server_pool" {
    display_name = "k3s-pool"

    compartment_id = var.compartment_ocid
    instance_configuration_id = module.compute.k3s_server_instance_configuration_id

    size = var.k3s_server_pool_size

    depends_on = [oci_identity_dynamic_group.k3s_pool]

    lifecycle {
        create_before_destroy = true
        ignore_changes = [load_balancers]
    }

    placement_configurations {
        availability_domain = var.k3s_availability_domain
    }
}

resource "oci_core_instance_pool" "k3s_agent_pool" {
    display_name = "k3s-pool"

    compartment_id = var.compartment_ocid
    instance_configuration_id = module.compute.k3s_server_instance_configuration_id

    depends_on = [oci_identity_dynamic_group.k3s_pool]

    lifecycle {
        create_before_destroy = true
        ignore_changes = [load_balancers]
    }

    placement_configurations {
        availability_domain = var.k3s_availability_domain
    }

    size = var.k3s_server_pool_size
}