module "cloudflared" {
  source = "./cloudflared"

  remote_server_ip = var.remote_server_ip

  remote_server_ssh_key  = var.remote_server_ssh_key
  remote_server_ssh_user = var.remote_server_ssh_user

  cloudflare_token      = var.cloudflare_token
  cloudflare_domain     = var.cloudflare_domain
  cloudflare_zone_id    = var.cloudflare_zone_id
  cloudflare_account_id = var.cloudflare_account_id
}
