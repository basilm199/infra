data "aws_ami" "latest" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["${var.project}-${var.env}-*"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
  filter {
    name   = "tag:project"
    values = ["${var.project}"]
  }
  filter {
    name   = "tag:env"
    values = ["${var.env}"]
  }
}
