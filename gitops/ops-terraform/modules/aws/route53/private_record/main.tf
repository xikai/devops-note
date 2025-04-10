locals {
  record_ip_pairs = flatten([
    for record in var.records_name : [
      for idx, ip in var.ec2_private_ip : {
        name = "${record}-${idx + 1}"
        ip   = ip
      }
    ]
  ])
}

resource "aws_route53_record" "record" {
  for_each = { for pair in local.record_ip_pairs : pair.name => pair }
  zone_id  = var.zone_id
  name     = each.value.name
  type     = "A"
  records  = [each.value.ip]
  ttl      = 300
}