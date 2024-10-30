resource "alicloud_nlb_load_balancer" "load-balancer" {
  load_balancer_name = "load-balancer"
  load_balancer_type = "Network"
  address_type       = "Internet"
  address_ip_version = "Ipv4"
  vpc_id             = alicloud_vpc.vpc.id
  zone_mappings {
    vswitch_id = alicloud_vswitch.public.id
    zone_id    = data.alicloud_zones.default.zones.0.id
  }
  zone_mappings {
    vswitch_id = alicloud_vswitch.public-b.id
    zone_id    = data.alicloud_zones.default.zones.1.id
  }
}

resource "alicloud_nlb_server_group" "server-group" {
  server_group_name        = "http"
  server_group_type        = "Instance"
  vpc_id                   = alicloud_vpc.vpc.id
  scheduler                = "rr"
  protocol                 = "TCP"
  connection_drain_enabled = true
  connection_drain_timeout = 60
  address_ip_version       = "Ipv4"
  health_check {
    health_check_enabled         = true
    health_check_type            = "TCP"
    health_check_connect_port    = 0
    healthy_threshold            = 2
    unhealthy_threshold          = 2
    health_check_connect_timeout = 5
    health_check_interval        = 10
    http_check_method            = "GET"
    health_check_http_code       = ["http_2xx", "http_3xx", "http_4xx"]
  }

}

resource "alicloud_nlb_server_group_server_attachment" "server-group-attachem" {
  count           = length(alicloud_instance.web-instance)
  server_type     = "Ecs"
  server_id       = alicloud_instance.web-instance[count.index].id
  description     = "http"
  port            = 5000
  server_group_id = alicloud_nlb_server_group.server-group.id
  weight          = 100
}

resource "alicloud_nlb_listener" "listener" {
  listener_protocol      = "TCP"
  listener_port          = "80"
  listener_description   = "http"
  load_balancer_id       = alicloud_nlb_load_balancer.load-balancer.id
  server_group_id        = alicloud_nlb_server_group.server-group.id
  idle_timeout           = "900"
  proxy_protocol_enabled = "false"
  cps                    = "0"
  mss                    = "0"
}

output "nlb_domain_name" {
  value = alicloud_nlb_load_balancer.load-balancer.dns_name
}