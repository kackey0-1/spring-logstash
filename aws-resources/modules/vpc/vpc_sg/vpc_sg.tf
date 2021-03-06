variable "ENV" {}
variable "PREFIX" {}
variable "VPC_ID" {}
variable "DEFAULT_TAGS" {}


resource "aws_security_group" "nginx_sg" {
  name        = "${var.PREFIX}-${var.ENV}-NGINX-SG"
  description = "Nginx security group"
  vpc_id      = var.VPC_ID
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
  var.DEFAULT_TAGS,
  map("Name", lower("${var.PREFIX}-${var.ENV}-NGINX-SG"))
  )
}

resource "aws_security_group" "spring_sg" {
  name        = "${var.PREFIX}-${var.ENV}-SPRING-SG"
  description = "Spring security group"
  vpc_id      = var.VPC_ID
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
  var.DEFAULT_TAGS,
  map("Name", lower("${var.PREFIX}-${var.ENV}-SPRING-SG"))
  )
}

resource "aws_security_group" "es_sg" {
  name        = "${var.PREFIX}-${var.ENV}-ES-SG"
  description = "Elasticsearch security group"
  vpc_id      = var.VPC_ID
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
  var.DEFAULT_TAGS,
  map("Name", lower("${var.PREFIX}-${var.ENV}-ES-SG"))
  )
}

resource "aws_security_group_rule" "nginx_sg_internet_ssh_rule" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  security_group_id = aws_security_group.nginx_sg.id
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "nginx_sg_internet_https_rule" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  security_group_id = aws_security_group.nginx_sg.id
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "nginx_sg_internet_http_rule" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  security_group_id = aws_security_group.nginx_sg.id
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "spring_sg_nginx_ssh_rule" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  security_group_id = aws_security_group.spring_sg.id
  source_security_group_id = aws_security_group.nginx_sg.id
}


resource "aws_security_group_rule" "es_sg_spring_https_rule" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  security_group_id = aws_security_group.es_sg.id
  source_security_group_id  = aws_security_group.spring_sg.id
}

resource "aws_security_group_rule" "es_sg_nginx_https_rule" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  security_group_id = aws_security_group.es_sg.id
  source_security_group_id  = aws_security_group.nginx_sg.id
}


resource "aws_security_group_rule" "es_sg_nginx_http_rule" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  security_group_id = aws_security_group.es_sg.id
  source_security_group_id  = aws_security_group.nginx_sg.id
}

output "security_group_map" {
  description = "security groups created in this vpc"
  value       = {
    "nginx" = aws_security_group.nginx_sg.id
    "es"    = aws_security_group.es_sg.id
    "spring" = aws_security_group.spring_sg.id
  }
}
