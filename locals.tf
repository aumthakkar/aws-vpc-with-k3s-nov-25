locals {
  public_cidr = [for i in range(2, 255, 2) : cidrsubnet(var.vpc_cidr, 8, i)]
}

locals {
  public_cidr_block = var.auto_create_public_subnets ? local.public_cidr : var.public_subnet_cidr_block
}

locals {
  security_groups = {
    public = {
      name        = "${var.name_prefix}-public-security-group"
      description = "${var.name_prefix}-public-security-group"
      tags = {
        Name = "${var.name_prefix}-public-security-group"
      }

      ingress = {
        ssh = {
          from        = 22
          to          = 22
          protocol    = "tcp"
          cidr_blocks = [var.ssh_access_ip]
        }
        http = {
          from        = 80
          to          = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
    rds = {
      name        = "${var.name_prefix}-db-instance"
      description = "MySql DB Instance"
      tags = {
        Name = "${var.name_prefix}-MySql DB instance"
      }
      ingress = {
        ssh = {
          from        = 3306
          to          = 3306
          protocol    = "tcp"
          cidr_blocks = [var.vpc_cidr]
        }
      }
    }
  }
}
