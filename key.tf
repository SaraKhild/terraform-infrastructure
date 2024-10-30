resource "alicloud_ecs_key_pair" "key-pairs" {
  key_pair_name   = "key-pairs"  
  key_file        = "key-pairs.pem"
}