resource "alicloud_instance" "web-instance" {
  count                      = 2
  availability_zone          = data.alicloud_zones.default.zones.0.id
  instance_name              = "web-${count.index}"
  instance_type              = "ecs.g6.large"
  image_id                   = "ubuntu_24_04_x64_20G_alibase_20240812.vhd"
  security_groups            = [alicloud_security_group.web-sg.id]
  internet_charge_type       = "PayByTraffic"
  instance_charge_type       = "PostPaid"
  system_disk_category       = "cloud_essd"
  vswitch_id                 = alicloud_vswitch.private.id
  key_name                   = alicloud_ecs_key_pair.key-pairs.key_pair_name
  internet_max_bandwidth_out = 0
  user_data = base64encode(templatefile("web-setup.tpl", {
    redis_host  = alicloud_instance.redis-instance.private_ip,
    db_host     = alicloud_instance.db-instance.private_ip,
    db_user     = var.db_user,
    db_password = var.db_password,
    db_name     = var.db_name
  }))

}

output "web_private_ips" {
  value = alicloud_instance.web-instance.*.private_ip
}