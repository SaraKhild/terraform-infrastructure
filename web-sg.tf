resource "alicloud_security_group" "web-sg" {
  description = "web-sg"
  vpc_id      = alicloud_vpc.vpc.id
}
resource "alicloud_security_group_rule" "allow-web-to-ssh" {
  type                     = "ingress"
  ip_protocol              = "tcp"
  policy                   = "accept"
  port_range               = "22/22"
  priority                 = 1
  security_group_id        = alicloud_security_group.web-sg.id
  source_security_group_id = alicloud_security_group.bastion-sg.id
}