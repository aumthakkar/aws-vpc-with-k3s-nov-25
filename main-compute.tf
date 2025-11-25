data "aws_ami" "ubuntu_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "my_ec2_key" {
  key_name   = var.key_name
  public_key = var.public_key

  tags = {
    Name = "${var.name_prefix}-ec2-public-key"
  }
}

resource "random_id" "k3s_instance_id" {
  byte_length = 2

  keepers = {
    key_name = var.key_name
  }
}

resource "aws_instance" "my_k3s_instance" {
  count = var.k3s_instance_count

  ami           = data.aws_ami.ubuntu_ami.id
  instance_type = var.ec2_instance_type

  key_name = aws_key_pair.my_ec2_key.key_name

  user_data = templatefile("${path.module}/scripts/userdata.tftpl", {
    nodename    = "${var.name_prefix}-${random_id.k3s_instance_id.dec}",
    dbuser      = var.db_username,
    dbpassword  = var.db_password,
    db_endpoint = aws_db_instance.my_db_instance.endpoint,
    dbname      = var.db_name
  })

  subnet_id       = aws_subnet.my_public_subnets[0].id
  security_groups = [aws_security_group.my_public_security_group["public"].id]

  root_block_device {
    volume_size = var.k3s_instance_vol_size
  }

  tags = {
    Name = "${var.name_prefix}-${random_id.k3s_instance_id.dec}"
  }
}

resource "aws_lb_target_group_attachment" "my_lb_ec2_target_attachment" {
  count = var.k3s_instance_count

  target_group_arn = aws_lb_target_group.my_lb_target_group.arn
  target_id        = aws_instance.my_k3s_instance[count.index].id

  port = var.lb_tg_port
}