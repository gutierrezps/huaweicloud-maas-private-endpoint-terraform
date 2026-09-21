data "huaweicloud_vpn_gateway_availability_zones" "local" {
  flavor          = "professional2"
  attachment_type = "vpc"
}

resource "huaweicloud_vpn_gateway" "local" {
  name           = "vpngw-local"
  vpc_id         = huaweicloud_vpc.local.id
  local_subnets  = [huaweicloud_vpc.local.cidr]
  connect_subnet = huaweicloud_vpc_subnet.local.id
  availability_zones = [
    data.huaweicloud_vpn_gateway_availability_zones.local.names[0],
    data.huaweicloud_vpn_gateway_availability_zones.local.names[1]
  ]

  eip1 {
    bandwidth_name = "bandwidth-vpngw-local1"
    type           = "5_bgp"
    bandwidth_size = 100
    charge_mode    = "traffic"
  }

  eip2 {
    bandwidth_name = "bandwidth-vpngw-local2"
    type           = "5_bgp"
    bandwidth_size = 100
    charge_mode    = "traffic"
  }
}

resource "huaweicloud_vpn_customer_gateway" "remote1" {
  name     = "vpngw-remote1"
  id_type  = "ip"
  id_value = huaweicloud_vpn_gateway.remote.eip1[0].ip_address
}

resource "huaweicloud_vpn_customer_gateway" "remote2" {
  name     = "vpngw-remote2"
  id_type  = "ip"
  id_value = huaweicloud_vpn_gateway.remote.eip2[0].ip_address
}

resource "huaweicloud_vpn_connection" "local1_to_remote1" {
  name                = "vpn-connection-local1-to-remote1"
  gateway_id          = huaweicloud_vpn_gateway.local.id
  gateway_ip          = huaweicloud_vpn_gateway.local.eip1[0].id
  customer_gateway_id = huaweicloud_vpn_customer_gateway.remote1.id
  peer_subnets        = [huaweicloud_vpc.remote.cidr]
  vpn_type            = "static"
  psk                 = random_password.vpn_psk.result
}

resource "huaweicloud_vpn_connection" "local2_to_remote2" {
  name                = "vpn-connection-local2-to-remote2"
  gateway_id          = huaweicloud_vpn_gateway.local.id
  gateway_ip          = huaweicloud_vpn_gateway.local.eip2[0].id
  customer_gateway_id = huaweicloud_vpn_customer_gateway.remote2.id
  peer_subnets        = [huaweicloud_vpc.remote.cidr]
  vpn_type            = "static"
  psk                 = random_password.vpn_psk.result
}
