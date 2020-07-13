provider "aws" {
        profile = "task1"
        region  = "ap-south-1"
}
resource "aws_key_pair" "keypair" {
  key_name   = "eks"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}
resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = "vpc-b4e8f5dc"

  ingress {
    description = "http from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ssh from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http"
  }
}
resource "aws_instance" "myterraformos1" {
  ami = "ami-0447a12f28fddb066"
  instance_type = "t2.micro"
  key_name = "eks"
  security_groups = ["allow_http"]

  connection {
     type = "ssh"
     user = "ec2-user"
     private_key = file("/home/sachinkumarkashyap/Downloads/HBCloud/Terraform/eks.pem")
     host = aws_instance.myterraformos1.public_ip
}
 provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd  php git -y",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd",
    ]
  }

  tags = {
    Name = "OSterraform"
  }
}
output "az_id" {
    value = aws_instance.myterraformos1.availability_zone
}
output "publicip" {
  value = aws_instance.myterraformos1.public_ip
}

resource "aws_ebs_volume" "volterraform" {
  availability_zone = "ap-south-1a"
  size              = 1

  tags = { 
    Name = "volforterraform"
  }
}
resource "aws_volume_attachment" "attachvol" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.volterraform.id}"
  instance_id = "${aws_instance.myterraformos1.id}"
  force_detach = true
}

resource "null_resource" "localsystem2"  {
	provisioner "local-exec" {
	    command = "echo  ${aws_instance.myterraformos1.public_ip} > publicip.txt"
  	}
}

resource "null_resource" "remotesystem1"  {

depends_on = [
    aws_volume_attachment.attachvol,
  ]


  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("/home/sachinkumarkashyap/Downloads/HBCloud/Terraform/eks.pem")
    host = aws_instance.myterraformos1.public_ip
  }

provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4  /dev/xvdh",
      "sudo mount  /dev/xvdh  /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/aaditya2801/terraformjob1.git /var/www/html/"
    ]
  }
}



resource "null_resource" "localsystem3"  {


depends_on = [
    aws_ebs_snapshot.snap1,
  ]

	provisioner "local-exec" {
	    command = "start chrome  ${aws_instance.myterraformos1.public_ip}"
  	}
}
resource "aws_s3_bucket" "s3bucketjob1" {
  bucket = "mynewbucketforjob1"
  acl    = "private"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
resource "aws_s3_bucket_public_access_block" "publicaccess" {
  bucket = "${aws_s3_bucket.s3bucketjob1.id}"

  block_public_acls   = true
  block_public_policy = true
}
locals {
s3_origin_id = "myS3Origin"
}
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "oaiforjob1"
}
data "aws_iam_policy_document" "oaipolicy" {
  statement {
    actions   = ["s3:GetObject"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.oai.iam_arn}"]
    }
    resources = ["${aws_s3_bucket.s3bucketjob1.arn}"]
    }
  }

resource "aws_s3_bucket_policy" "bucketpolicy" {
  bucket = "${aws_s3_bucket.s3bucketjob1.id}"
  policy = "${data.aws_iam_policy_document.oaipolicy.json}"
}
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.s3bucketjob1.bucket_regional_domain_name}"
    origin_id   = "${local.s3_origin_id}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path}"
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = "mylogs.s3.amazonaws.com"
    prefix          = "myprefix"
  }

  aliases = ["mysite.example.com", "yoursite.example.com"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
resource "aws_ebs_snapshot" "snap1" {
  volume_id = "${aws_ebs_volume.volterraform.id}"

  tags = {
    Name = "job1snap"
  }
}
