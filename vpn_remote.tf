data "huaweicloud_vpn_gateway_availability_zones" "remote" {
  region          = local.remote_region
  flavor          = "professional1"
  attachment_type = "vpc"
}

resource "huaweicloud_vpn_gateway" "remote" {
  region         = local.remote_region
  name           = "vpngw-remote"
  vpc_id         = huaweicloud_vpc.remote.id
  local_subnets  = [huaweicloud_vpc.remote.cidr]
  connect_subnet = huaweicloud_vpc_subnet.remote.id
  availability_zones = [
    data.huaweicloud_vpn_gateway_availability_zones.remote.names[0],
    data.huaweicloud_vpn_gateway_availability_zones.remote.names[1]
  ]

  eip1 {
    bandwidth_name = "bandwidth-vpngw-remote1"
    type           = "5_bgp"
    bandwidth_size = 100
    charge_mode    = "traffic"
  }

  eip2 {
    bandwidth_name = "bandwidth-vpngw-remote2"
    type           = "5_bgp"
    bandwidth_size = 100
    charge_mode    = "traffic"
  }
}

resource "huaweicloud_vpn_customer_gateway" "local1" {
  region   = local.remote_region
  name     = "vpngw-local1"
  id_type  = "ip"
  id_value = huaweicloud_vpn_gateway.local.eip1[0].ip_address
}

resource "huaweicloud_vpn_customer_gateway" "local2" {
  region   = local.remote_region
  name     = "vpngw-local2"
  id_type  = "ip"
  id_value = huaweicloud_vpn_gateway.local.eip2[0].ip_address
}

resource "huaweicloud_vpn_connection" "remote1_to_local1" {
  region              = local.remote_region
  name                = "vpn-connection-remote1-to-local1"
  gateway_id          = huaweicloud_vpn_gateway.remote.id
  gateway_ip          = huaweicloud_vpn_gateway.remote.eip1[0].id
  customer_gateway_id = huaweicloud_vpn_customer_gateway.local1.id
  peer_subnets        = [huaweicloud_vpc.local.cidr]
  vpn_type            = "static"
  psk                 = random_password.vpn_psk.result
}

resource "huaweicloud_vpn_connection" "remote2_to_local2" {
  region              = local.remote_region
  name                = "vpn-connection-remote2-to-local2"
  gateway_id          = huaweicloud_vpn_gateway.remote.id
  gateway_ip          = huaweicloud_vpn_gateway.remote.eip2[0].id
  customer_gateway_id = huaweicloud_vpn_customer_gateway.local2.id
  peer_subnets        = [huaweicloud_vpc.local.cidr]
  vpn_type            = "static"
  psk                 = random_password.vpn_psk.result
}
