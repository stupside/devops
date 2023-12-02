variable "remote_server_ip" {
  type = string
}

variable "remote_server_ssh_user" {
  type      = string
  sensitive = true
}

variable "remote_server_ssh_key" {
  type      = string
  sensitive = true
}

variable "cloudflare_token" {
  type      = string
  sensitive = true
}

variable "cloudflare_domain" {
  type = string
}

variable "cloudflare_zone_id" {
  type = string
}

variable "cloudflare_account_id" {
  type = string
}
