resource "alicloud_security_group" "bastion-sg" {
  name        = "bastion_sg"
  description = "bastion_sg"
  vpc_id      = alicloud_vpc.vpc.id
}
resource "alicloud_security_group_rule" "allow-bastion_to_ssh" {
  type              = "ingress"
  ip_protocol       = "tcp"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = alicloud_security_group.bastion-sg.id
  cidr_ip           = "0.0.0.0/0"
}