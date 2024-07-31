# https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm
# https://docs.oracle.com/en-us/iaas/tools/terraform-provider-oci/5.38/docs/r/core_instance_configuration.html

resource "oci_core_instance_configuration" "instance_configuration_server" {
  compartment_id = var.compartment_id

  display_name = "${var.name}-instance-configuration-server"

  instance_details {
    instance_type = "compute"

    launch_details {
      shape = var.server_shape

      shape_config {
        ocpus         = 2
        memory_in_gbs = 4
      }

      source_details {
        source_type = "image"
        boot_volume_size_in_gbs = var.server_instance_volume
      }
    }
  }
}

resource "oci_core_instance_configuration" "instance_configuration_agent" {
  compartment_id = var.compartment_id

  display_name = "${var.name}-instance-configuration-agent"

  instance_details {
    instance_type = "compute"

    launch_details {
      shape = var.agent_shape

      shape_config {
        ocpus         = 1
        memory_in_gbs = 2
      }

      source_details {
        source_type = "image"
        boot_volume_size_in_gbs = var.agent_instance_volume
      }
    }
  }
}
