resource "aws_route53_zone" "private" {
  name = "${var.project_name}-${var.env}.${var.zone_suffix}"

  vpc {
    vpc_id = var.vpc_id
  }
}