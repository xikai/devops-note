resource "aws_key_pair" "ssh_key" {
   key_name   = "${var.project_name}-${var.env}"
   public_key = var.public_key
   tags = {
      Name        = "${var.env}-${var.project_name}-public-key"
      Project     = var.project_name
      Environment = var.env
   }
}