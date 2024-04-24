# https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm
# https://docs.oracle.com/en-us/iaas/tools/terraform-provider-oci/5.38/docs/r/core_instance_configuration.html

resource "oci_core_instance_configuration" "k3s_server" {
    compartment_id = var.compartment_id

    display_name = "k3s-server"

    instance_details {
      instance_type = "compute"

      launch_details {
        shape = var.k3s_server_shape

        shape_config {
            ocpus = 1
            memory_in_gbs = 2
        }
      }
    }
}

resource "oci_core_instance_configuration" "k3s_agent" {
    compartment_id = var.compartment_id

    display_name = "k3s-agent"

    instance_details {
      instance_type = "compute"

      launch_details {
        shape = var.k3s_agent_shape

        shape_config {
            ocpus = 4
            memory_in_gbs = 6
        }
      }
    }
}