variable subnet_ids            {}  # The AWS Subnet Id to place the lb into
variable resource_tags         {}  # AWS tags to apply to resources
variable vpc_id                {}  # The VPC Id
variable bosh_domain           {}  # url used for bosh domain
variable route53_zone_id       {}  # Route53 zone id
variable security_groups       {}  # Array of security groups to use
variable bosh_acm_arn          {}  # ACM arn for the bosh certificates
variable internal_lb           { default = true } # Determine whether the load balancer is internal-only facing
variable env_type              { default = "ocf" }

variable enable_route_53       { default = 1 }  # Disable if using CloudFlare or other DNS


################################################################################
# BOSH ALB
################################################################################
resource "aws_lb" "bosh_alb" {
  name               = "${var.env_typ}-bosh-alb"
  internal           = var.internal_lb
  load_balancer_type = "application"
  subnets            = var.subnet_ids
  security_groups    = var.security_groups
  tags               = merge({Name = "bosh-alb"}, var.resource_tags)
}

################################################################################
# BOSH ALB Target Group
################################################################################
resource "aws_lb_target_group" "bosh_alb_tg" {
  name     = "${var.env_typ}-bosh-alb-tg"
  port     = 8443
  protocol = "HTTPS"
  vpc_id   = var.vpc_id
  tags     = merge({Name = "${var.env_typ}-bosh-alb-tg"}, var.resource_tags)
  health_check {
    path = "/healthz"
    port = 8443
    protocol = "HTTPS"
  }
}


################################################################################
# BOSH ALB Listeners - bosh API - HTTPS
################################################################################
resource "aws_alb_listener" "bosh_alb_listener_443" {
  load_balancer_arn = aws_lb.bosh_alb.arn
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn = var.bosh_acm_arn
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.bosh_alb_tg.arn
  }
  tags = merge({Name = "bosh-alb-listener-443"}, var.resource_tags)
}


################################################################################
# bosh ALB Route53 DNS
################################################################################
resource "aws_route53_record" "bosh_lb_record" {

  count   = var.enable_route_53
  zone_id = var.route53_zone_id
  name    = var.bosh_domain
  type    = "CNAME"
  ttl     = "60"
  records = ["${aws_lb.bosh_alb.dns_name}"]
}


output "dns_name" {value = aws_lb.bosh_alb.dns_name}
output "lb_name"  {value = aws_lb.bosh_alb.name }
output "lb_target_group_name" { value = aws_lb_target_group.bosh_alb_tg.name }