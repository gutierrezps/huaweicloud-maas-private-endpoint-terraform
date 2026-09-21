locals {
  remote_region = "ap-southeast-1"
  remote_az     = "ap-southeast-1a"
}

resource "huaweicloud_vpc" "local" {
  name = "vpc-local"
  cidr = "172.16.0.0/16"
}

resource "huaweicloud_vpc_subnet" "local" {
  name              = "subnet-local"
  cidr              = "172.16.0.0/24"
  gateway_ip        = "172.16.0.1"
  vpc_id            = huaweicloud_vpc.local.id
  availability_zone = var.availability_zone
}

resource "huaweicloud_vpc" "remote" {
  region = local.remote_region
  name   = "vpc-remote"
  cidr   = "172.17.0.0/16"
}

resource "huaweicloud_vpc_subnet" "remote" {
  region            = local.remote_region
  name              = "subnet-remote"
  cidr              = "172.17.0.0/24"
  gateway_ip        = "172.17.0.1"
  vpc_id            = huaweicloud_vpc.remote.id
  availability_zone = local.remote_az
}

resource "random_password" "vpn_psk" {
  length           = 24
  special          = true
  override_special = "~!@#$%^()-_+={ },./:;"
}
