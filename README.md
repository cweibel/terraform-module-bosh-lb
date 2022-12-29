# terraform-module-bosh-lb
Terraform module to create the ALB for BOSH


Inputs - Required:

 - `resource_tags` - AWS tags to apply to resources
 - `vpc_id` - AWS VPC Id
 - `subnet_ids` - The AWS Subnet Id to place the lb into     
 - `bosh_domain` - url used for bosh domain
 - `route53_zone_id` - Route53 zone id
 - `security_groups` - Array of security groups to use on the lb
 - `bosh_acm_arn` - ACM arn for the bosh urls

Inputs - Optional: 

 - `enable_route_53` - Disable if using CloudFlare or other DNS (default = 1, to disable, set = 0)
 - `internal_lb` - Determine whether the load balancer is internal-only facing (default = true)
 
Outputs:

 - `dns_name` - The A Record for the created load balancer
 - `lb_name` - Name of the load balancer.  Map this value in your cloud config
 - `lb_target_group_name` - Name of the target group