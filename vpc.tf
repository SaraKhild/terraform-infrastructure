data "alicloud_zones" "default" {
  available_disk_category     = "cloud_efficiency"
  available_resource_creation = "VSwitch"
}

resource "alicloud_vpc" "vpc" {
  vpc_name   = "vpc"
  cidr_block = "10.0.0.0/8"
}

resource "alicloud_vswitch" "public" {
  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = "10.0.1.0/24"
  zone_id      = data.alicloud_zones.default.zones.0.id
  vswitch_name = "public"
}
resource "alicloud_vswitch" "public-b" {
  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = "10.0.3.0/24"
  zone_id      = data.alicloud_zones.default.zones.1.id
  vswitch_name = "public-b"
}

resource "alicloud_vswitch" "private" {
  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = "10.0.2.0/24"
  zone_id      = data.alicloud_zones.default.zones.0.id
  vswitch_name = "private"
}


resource "alicloud_nat_gateway" "gateway" {
  vpc_id           = alicloud_vpc.vpc.id
  nat_type         = "Enhanced"
  nat_gateway_name = "nat"
  vswitch_id       = alicloud_vswitch.public.id
  payment_type     = "PayAsYouGo"
}

resource "alicloud_eip_address" "eip-address" {
  netmode              = "public"
  bandwidth            = "100"
  internet_charge_type = "PayByTraffic"
  payment_type         = "PayAsYouGo"
}

resource "alicloud_eip_association" "eip-association" {
  allocation_id = alicloud_eip_address.eip-address.id
  instance_id   = alicloud_nat_gateway.gateway.id
  instance_type = "Nat"
}

resource "alicloud_snat_entry" "snat-entry" {
  snat_table_id     = alicloud_nat_gateway.gateway.snat_table_ids
  source_vswitch_id = alicloud_vswitch.private.id
  snat_ip           = alicloud_eip_address.eip-address.ip_address
}

resource "alicloud_route_table" "route-table" {
  description      = "private-a_rt"
  vpc_id           = alicloud_vpc.vpc.id
  route_table_name = "private-a_rt"
  associate_type   = "VSwitch"
}
resource "alicloud_route_entry" "route-entry" {
  route_table_id        = alicloud_route_table.route-table.id
  destination_cidrblock = "0.0.0.0/0"
  nexthop_type          = "NatGateway"
  nexthop_id            = alicloud_nat_gateway.gateway.id
}


resource "alicloud_route_table_attachment" "table-attachment" {
  vswitch_id     = alicloud_vswitch.private.id
  route_table_id = alicloud_route_table.route-table.id
}