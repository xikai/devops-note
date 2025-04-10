resource "aws_ec2_managed_prefix_list" "prefix_list" {
  name           = "${var.env}-${var.project_name}-${var.prefix_name}-prefix"
  address_family = "IPv4"
  max_entries    = length(var.prefix_list_entries)
  tags = {
    Name          = "${var.env}-${var.project_name}-prefix"
    Project       = var.project_name
    Environment   = var.env
  }
}

resource "aws_ec2_managed_prefix_list_entry" "prefix_list_entry" {
  count            = length(var.prefix_list_entries)
  prefix_list_id = aws_ec2_managed_prefix_list.prefix_list.id
  cidr             = "${element(var.prefix_list_entries[count.index], 0)}"
  description      = "${element(var.prefix_list_entries[count.index], 1)}"
}

#另一种写法
# resource "aws_ec2_managed_prefix_list_entry" "prefix_list_entry" {
#   prefix_list_id = aws_ec2_managed_prefix_list.prefix_list.id
#   for_each       = { for idx,entry in var.prefix_list_entries : idx => entry}
#   cidr           = each.value.cidr
#   description    = each.value.description
# }