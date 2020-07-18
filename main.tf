provider "aws" {
        profile = "task1"
        region= "ap-south-1"
	access_key="AKIAJLRH3UXU3H23ELQQ"
	secret_key="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"
}


resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = "vpc-d2b985ba"

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
resource "aws_instance" "my_task1_os" {
  ami = "ami-0447a12f28fddb066"
  instance_type = "t2.micro"
  key_name = "eks"
  security_groups = ["allow_http"]

  connection {
     type = "ssh"
     user = "ec2-user"
     private_key = file("/home/sachinkumarkashyap/Downloads/hmc/Terraform/eks.pem")
     host = aws_instance.my_task1_os.public_ip
}
 provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd  php git -y",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd",
    ]
  }

  tags = {
    Name = "os1"
  }
}
output "az_id" {
    value = aws_instance.my_task1_os.availability_zone
}
output "publicip" {
  value = aws_instance.my_task1_os.public_ip
}

resource "aws_ebs_volume" "task1_ebs" {
  availability_zone = "ap-south-1a"
  size              = 1

  tags = { 
    Name = "task1_ebs"
  }
}
resource "aws_volume_attachment" "attachvol" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.task1_ebs.id}"
  instance_id = "${aws_instance.my_task1_os.id}"
  force_detach = true
}

resource "null_resource" "localsystem2"  {
	provisioner "local-exec" {
	    command = "echo  ${aws_instance.my_task1_os.public_ip} > publicip.txt"
  	}
}

resource "null_resource" "remotesystem1"  {

depends_on = [
    aws_volume_attachment.attachvol,
  ]


  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("/home/sachinkumarkashyap/Downloads/hmc/Terraform/eks.pem")
    host = aws_instance.my_task1_os.public_ip
  }

provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4  /dev/xvdh",
      "sudo mount  /dev/xvdh  /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/hackcoderr/Mini-Project.git /var/www/html/"
    ]
  }
}



resource "null_resource" "localsystem3"  {


depends_on = [
    aws_ebs_snapshot.snap1,
  ]

	provisioner "local-exec" {
	    command = "start chrome  ${aws_instance.my_task1_os.public_ip}"
  	}
}
resource "aws_s3_bucket" "task1_s3" {
  bucket = "my_task1_s3"
  acl    = "private"

  tags = {
    Name        = "my_task1_s3"
    Environment = "Dev"
  }
}
resource "aws_s3_bucket_public_access_block" "publicaccess" {
  bucket = "${aws_s3_bucket.task1_s3.id}"

  block_public_acls   = true
  block_public_policy = true
}
locals {
s3_origin_id = "myS3Origin"
}
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "oai_for_task1"
}
data "aws_iam_policy_document" "oaipolicy" {
  statement {
    actions   = ["s3:GetObject"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.oai.iam_arn}"]
    }
    resources = ["${aws_s3_bucket.task1_s3.arn}"]
    }
  }

resource "aws_s3_bucket_policy" "bucketpolicy" {
  bucket = "${aws_s3_bucket.task1_s3.id}"
  policy = "${data.aws_iam_policy_document.oaipolicy.json}"
}
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.task1_s3.bucket_regional_domain_name}"
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
  volume_id = "${aws_ebs_volume.task1_ebs.id}"

  tags = {
    Name = "job1snap"
  }
}
