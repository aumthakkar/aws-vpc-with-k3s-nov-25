# Networking variables
variable "vpc_cidr" {}
variable "name_prefix" {}

variable "public_subnet_count" {}

variable "auto_create_public_subnets" {
  type = bool
}
variable "public_subnet_cidr_block" {}

variable "ssh_access_ip" {}

# Loadbalancing

variable "lb_tg_port" {}
variable "lb_tg_protocol" {}

variable "lb_healthy_threshold" {}
variable "lb_unhealthy_threshold" {}
variable "lb_interval" {}
variable "lb_timeout" {}

variable "lb_listener_port" {}
variable "lb_listener_protocol" {}

# Database
variable "db_storage" {}
variable "db_name" {}

variable "db_identifier" {}
variable "db_instance_class" {}

variable "db_username" {}
variable "db_password" {}

variable "db_engine" {}
variable "db_engine_version" {}


variable "skip_db_final_snapshot" {
  type = bool
}

# Compute

variable "k3s_instance_count" {}
variable "public_key_path" {}

variable "ec2_instance_type" {}
variable "key_name" {}

variable "k3s_instance_vol_size" {}