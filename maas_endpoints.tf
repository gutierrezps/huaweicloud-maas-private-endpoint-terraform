data "huaweicloud_vpcep_service_summary" "maas1" {
  region                = local.remote_region
  endpoint_service_name = var.maas_endpoint_service_id_1
}

data "huaweicloud_vpcep_service_summary" "maas2" {
  region                = local.remote_region
  endpoint_service_name = var.maas_endpoint_service_id_2
}

resource "huaweicloud_vpcep_endpoint" "maas1" {
  region     = local.remote_region
  service_id = data.huaweicloud_vpcep_service_summary.maas1.id
  vpc_id     = huaweicloud_vpc.remote.id
  network_id = huaweicloud_vpc_subnet.remote.id
  enable_dns = false
}

resource "huaweicloud_vpcep_endpoint" "maas2" {
  region     = local.remote_region
  service_id = data.huaweicloud_vpcep_service_summary.maas2.id
  vpc_id     = huaweicloud_vpc.remote.id
  network_id = huaweicloud_vpc_subnet.remote.id
  enable_dns = false
}
