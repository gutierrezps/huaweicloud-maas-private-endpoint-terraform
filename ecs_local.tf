data "http" "ingress_ip_address" {
  # Returns public IP address of this machine,
  # that is executing this Terraform code.
  # SSH to the ecs-local machine will only be allowed from this machine.

  url = "https://api.ipify.org/"
}

locals {
  ingress_ip_address = trimspace(data.http.ingress_ip_address.response_body)
}

resource "huaweicloud_networking_secgroup" "local" {
  name                 = "sg-local"
  delete_default_rules = true
}

resource "huaweicloud_networking_secgroup_rule" "local_egr" {
  security_group_id = huaweicloud_networking_secgroup.local.id
  direction         = "egress"
  ethertype         = "IPv4"
}

resource "huaweicloud_networking_secgroup_rule" "local_egr_v6" {
  security_group_id = huaweicloud_networking_secgroup.local.id
  direction         = "egress"
  ethertype         = "IPv6"
}

resource "huaweicloud_networking_secgroup_rule" "local_ing_ssh" {
  security_group_id = huaweicloud_networking_secgroup.local.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  ports             = "22"
  remote_ip_prefix  = "${local.ingress_ip_address}/32"
}

data "huaweicloud_compute_flavors" "local" {
  availability_zone = var.availability_zone
  performance_type  = "normal"
  cpu_core_count    = 1
  memory_size       = 2
}

resource "huaweicloud_vpc_eip" "local" {
  name = "eip-ecs-local"

  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "bandwidth-eip-ecs-local"
    size        = 300
    share_type  = "PER"
    charge_mode = "traffic"
  }
}

resource "huaweicloud_compute_instance" "local" {
  name               = "ecs-local"
  image_name         = "Ubuntu 24.04 server 64bit"
  flavor_id          = data.huaweicloud_compute_flavors.local.ids[0]
  admin_pass         = var.default_password
  security_group_ids = [huaweicloud_networking_secgroup.local.id]
  availability_zone  = var.availability_zone

  system_disk_type = "SAS"
  system_disk_size = 40

  eip_id = huaweicloud_vpc_eip.local.id

  agent_list = "ces"

  network {
    uuid = huaweicloud_vpc_subnet.local.id
  }
}