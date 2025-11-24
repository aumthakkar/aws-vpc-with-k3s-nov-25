resource "aws_lb" "my_lb" {
  name = "${var.name_prefix}-public-load-balancer"

  load_balancer_type = "application"

  security_groups = [aws_security_group.my_public_security_group["public"].id]
  subnets         = [for subnet in aws_subnet.my_public_subnets : subnet.id]

  tags = {
    Name = "${var.name_prefix}-alb"
  }
}

resource "aws_lb_target_group" "my_lb_target_group" {
  vpc_id = aws_vpc.my_vpc.id

  name = "${var.name_prefix}-lb-target-group"

  port     = var.lb_tg_port     # 80
  protocol = var.lb_tg_protocol # HTTP

  health_check {
    healthy_threshold   = var.lb_healthy_threshold
    unhealthy_threshold = var.lb_unhealthy_threshold
    interval            = var.lb_interval
    timeout             = var.lb_timeout

  }

  tags = {
    Name = "${var.name_prefix}-lb-tg"
  }
}

resource "aws_lb_listener" "my_alb_listener" {
  load_balancer_arn = aws_lb.my_lb.arn

  port     = var.lb_listener_port
  protocol = var.lb_listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_lb_target_group.arn
  }
}