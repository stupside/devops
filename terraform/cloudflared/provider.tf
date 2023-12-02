# Cloudflare provider definition
provider "cloudflare" {
  api_token = var.cloudflare_token
}

# Create a new DNS record for the tunnel
resource "cloudflare_record" "record" {
  type    = "A"
  name    = "www"
  value   = var.remote_server_ip
  zone_id = var.cloudflare_zone_id
  proxied = true
}

# Configure HTTPS for the tunnel
resource "cloudflare_zone_settings_override" "settings_override" {
  zone_id = var.cloudflare_zone_id
  settings {
    tls_1_3                  = "on"
    automatic_https_rewrites = "on"
    ssl                      = "strict"
  }
}

# Generate a random password
resource "random_password" "secret" {
  length = 64
}

# Create a locally-managed tunnel
resource "cloudflare_tunnel" "tunnel" {
  name       = "cloudflare_tunnel"
  account_id = var.cloudflare_account_id
  secret     = base64sha256(random_password.secret.result)
  depends_on = [random_password.secret]
}

# Generate a local file containing variables for Ansible
resource "local_file" "variables" {
  content = templatefile("ansible/variables.yaml.tftpl", {
    domain        = var.cloudflare_domain
    account_id    = var.cloudflare_account_id
    tunnel_id     = cloudflare_tunnel.tunnel.id
    tunnel_name   = cloudflare_tunnel.tunnel.name
    tunnel_secret = base64sha256(random_password.secret.b64_std)
  })

  filename = "./ansible/variables.yaml"

  depends_on = [cloudflare_tunnel.tunnel]
}

# Null resource for local execution of Ansible
resource "null_resource" "ansible" {
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ${var.remote_server_ssh_user} --private-key ${var.remote_server_ssh_key} -i ${var.remote_server_ip} ./ansible/playbook.yml"
  }

  depends_on = [local_file.variables]
}
