provider "aws" {

  region= var.aws_region
}
# Usa il modulo aws/module/http-80 di AWS per creare automaticamente un security group
# che permette la porta 80

module "http_80_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/http-80"
  version = "~> 3.0"
  vpc_id  = var.vpc_id
  name    = var.name
}
# Crea un load balancer con le security group di sopra

resource "aws_lb" "nlb" {
  name                       = "nlb-tf"
  internal                   = false
  load_balancer_type         = "network"
  subnets                    = values(var.public_subnet_ids)[*].id
  security_groups            = [module.http_80_security_group.this_security_group_id]
  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}
# Crea un load balancer target group per la porta 80
resource "aws_lb_target_group" "nlb-target-group" {
  name     = "nlb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

# Crea un load balancer listener sulla porta 80 con default_action "forward"
resource "aws_lb_listener" "nlb-listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb-target-group.arn
  }
}

# Recupera l'AMI di Amazon Linux 2

data "aws_ami" "amzn2" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.????????.?-x86_64-gp2"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}


# Crea un AWS key pair chiamata ssh
resource "aws_key_pair" "ssh" {
  key_name   = "aws_key"
  public_key = file("${path.module}/.ssh/ec2.pub")

}
# (genera una chiave localmente)


# Crea un launch configuration con l'AMI recuperata da sopra
# e i security group ottenuti dal modulo di AWS
# Il tipo di istanza dev'essere t2.micro
# Ricorda di includere la chiave SSH generata prima
# Inoltre, inserisci lo startup script contenuto in questa cartella come userdata

# Crea un autoscaling group con
# min_size 1
# desired_capacity 2
# max_size 4

# Crea un autoscaling policy con
# scaling adjustment 1
# adjustment_type ChangeInCapacity
# cooldown 300

resource "aws_launch_configuration" "web" {
  name_prefix     = "terraform-lc-example-"
  image_id        = data.aws_ami.amzn2.id
  instance_type   = "t2.micro"
  security_groups = [module.http_80_security_group.this_security_group_id]
  key_name        = aws.aws_key_pair.ssh.key_name
  user_data       = file("${path.module}/startup.sh") #no 64
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web-asg" {
  name = "asg-01"

  min_size         = 1
  desired_capacity = 2
  max_size         = 4

  health_check_type = "ELB"

  target_group_arns = aws_lb_target_group.nlb-target-group.arn

  launch_configuration = aws_launch_configuration.web.name

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  vpc_zone_identifier = values(var.private_subnets_ids)[*].id

  # Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_policy" "web_policy_up" {
  name                   = "web_policy_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws.aws_autoscaling_group.web-asg.name
}

# Crea un autoscaling policy con
# scaling adjustment -1
# adjustment_type ChangeInCapacity
# cooldown 300
resource "aws_autoscaling_policy" "web_policy_down" {
  name                   = "web_policy_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws.aws_autoscaling_group.web-asg.name
}

resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_up" {
  alarm_name          = "web_cpu_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "60"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web-asg.name
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = aws_autoscaling_policy.web_policy_up[*].arn
}

resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_down" {
  alarm_name          = "web_cpu_alarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web-asg.name
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = aws_autoscaling_policy.web_policy_down[*].arn
}
