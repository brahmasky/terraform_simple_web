# ============
#  Create a Launch template for web server instances to be used by ASG
# ============

# Retrieve the ID of the latest amazon linux AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_launch_template" "web_server_node" {
  name_prefix            = "${var.web_server_namespace}-"
  image_id               = data.aws_ami.amazon_linux.id
  instance_type          = var.ec2_instance_type
  key_name               = var.web_server_ssh_key
  monitoring {
    enabled = true
  }
  user_data              = filebase64("${path.module}/files/userdata.sh")
  vpc_security_group_ids = [var.web_server_sg_id]
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.web_server_namespace}-${terraform.workspace}"
    }
  }
  lifecycle {
    create_before_destroy = true
    # we don't want to create a new template just because there is a newer AMI
    ignore_changes = [
      image_id,
    ]
  }
}


# ============
#  Create auto scaling group to provision and manage the web server, one per each AZ
# ============
# default tags to be populated to instances
data "aws_default_tags" "current" {}

# total web server count = web server per az * az numbers
locals {
  web_server_count = var.web_server_count_per_az * length(var.az_names)
}

resource "aws_autoscaling_group" "web_server_asg" {
  name                      = "${var.web_server_namespace}-asg-${terraform.workspace}"
  min_size                  = local.web_server_count
  max_size                  = local.web_server_count
  desired_capacity          = local.web_server_count
  vpc_zone_identifier       = [for subnet in var.private_subnets : subnet.id]
  health_check_type         = "ELB"
  health_check_grace_period = 300
  target_group_arns         = [aws_alb_target_group.web_server_tg.arn]

  launch_template {
    id      = aws_launch_template.web_server_node.id
    version = "$Latest"
  }
  #  Recommended for auto-scaling groups and launch configurations.
  lifecycle {
    create_before_destroy = true
  }

  dynamic "tag" {
    for_each = data.aws_default_tags.current.tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

# ============
# Create applicaton load balancer and target group for the web servers
# ============
resource "aws_alb" "web_server_alb" {
  name            = "${var.web_server_namespace}-alb"
  security_groups = [var.web_server_alb_sg_id]
  subnets         = [for subnet in var.public_subnets : subnet.id]
  tags = {
    Name = "${var.web_server_namespace}-alb-${terraform.workspace}"
  }
}

resource "aws_alb_target_group" "web_server_tg" {
  name     = "${var.web_server_namespace}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_alb_listener" "web_server_listener" {
  load_balancer_arn = aws_alb.web_server_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.web_server_tg.arn
    type             = "forward"
  }
  tags = {
    Name = "${var.web_server_namespace}-tg-${terraform.workspace}"
  }
}


# ============
# Create a new ALB Target Group attachment
# ============
resource "aws_autoscaling_attachment" "web_server_attachment" {
  autoscaling_group_name = aws_autoscaling_group.web_server_asg.id
  alb_target_group_arn   = aws_alb_target_group.web_server_tg.arn
}


# ============
# Create bastion host in one public subnet for troubleshooting and/or maintenance
# ============

resource "aws_instance" "bastion_host" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name      = var.web_server_ssh_key

  vpc_security_group_ids      = [var.bastion_host_sg_id]
  subnet_id                   = var.public_subnets["${var.az_names[0]}"].id
  associate_public_ip_address = true
  tags = {
    Name = "bastion-host-${terraform.workspace}"
  }
}