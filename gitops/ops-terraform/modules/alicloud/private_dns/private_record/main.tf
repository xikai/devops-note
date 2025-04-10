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

resource "alicloud_pvtz_zone_record" "record" {
  for_each = { for pair in local.record_ip_pairs : pair.name => pair }
  zone_id = var.zone_id
  rr      = each.value.name
  type    = "A"
  value   = each.value.ip
  ttl     = 60
}

resource "alicloud_pvtz_zone_attachment" "zone-attachment" {
  zone_id = var.zone_id
  vpcs {
    vpc_id = var.vpc_id
  }
}