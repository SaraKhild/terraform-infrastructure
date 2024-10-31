resource "alicloud_security_group" "redis-sg" {
  description = "redis-sg"
  vpc_id      = alicloud_vpc.vpc.id
}
resource "alicloud_security_group_rule" "allow-redis-to-ssh" {
  type                     = "ingress"
  ip_protocol              = "tcp"
  policy                   = "accept"
  port_range               = "22/22"
  priority                 = 1
  security_group_id        = alicloud_security_group.redis-sg.id
  source_security_group_id = alicloud_security_group.bastion-sg.id
}


resource "alicloud_security_group_rule" "allow-web-to-redis" {
  type                     = "ingress"
  ip_protocol              = "tcp"
  policy                   = "accept"
  port_range               = "6379/6379"
  priority                 = 1
  security_group_id        = alicloud_security_group.redis-sg.id
  source_security_group_id = alicloud_security_group.web-sg.id
}