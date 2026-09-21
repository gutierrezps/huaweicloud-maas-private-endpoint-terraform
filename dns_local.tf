resource "huaweicloud_dns_zone" "maas" {
  name      = "api-ap-southeast-1.modelarts-maas.com"
  zone_type = "private"
  ttl       = 300

  router {
    router_id = huaweicloud_vpc.local.id
  }
}

resource "huaweicloud_dns_recordset" "maas" {
  zone_id = huaweicloud_dns_zone.maas.id
  name    = "api-ap-southeast-1.modelarts-maas.com"
  ttl     = 300
  type    = "A"
  records = [
    huaweicloud_vpcep_endpoint.maas1.ip_address,
    huaweicloud_vpcep_endpoint.maas2.ip_address
  ]
}