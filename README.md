## Launching-Webserver-on-AWS-cloud-using-Terraform
---

<img src="https://img-a.udemycdn.com/course/750x422/2476280_486f.jpg" width="1500" height="500" alt=""> 

---
## Amazon Web Service:
Amazon Web Services, or AWS, is a cloud computing platform from Amazon that provides customers with a wide array of cloud services. Among the cloud options offered by Amazon AWS are Amazon Elastic Compute Cloud (Amazon EC2), Amazon Simple Storage Service (Amazon S3), Amazon Virtual Private Cloud (Amazon VPC), Amazon SimpleDB and Amazon WorkSpaces.

Amazon first debuted its Amazon Web Services in 2006 as a way to enable the use of online services by client-side ---applications or other web sites via HTTP, REST or SOAP protocols. Amazon bills customers for Amazon AWS based on their usage of the various Amazon Web Services.

In 2012, Amazon launched the AWS Marketplace to accommodate and grow the emerging ecosystem of AWS offerings from third-party providers that have built their own solutions on top of the Amazon Web Services platform. The AWS Marketplace is an online store for Amazon Web Services customers to find, compare and begin using AWS software and technical services.
links
[Visit website](https://aws.amazon.com/console/)

---
## Terraform
Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently. Terraform can manage existing and popular service providers as well as custom in-house solutions. Configuration files describe to Terraform the components needed to run a single application or your entire datacenter.
links.
[Visit website](https://www.terraform.io/)

---
## Aim
In this task I have integrated Terraform and AWS to create an infrastructure for launching an application on cloud using the EC2 service provided by AWS and using Terraform automated the whole process. The reason for doing so is that creating this infrastructure manually would be time consuming which is not an option in this agile world so using terraform we can automate the whole process and create the infrastructure for our application faster.

>Problem Statement:
```
1. Create the key and security group which allow the port 80.

2. Launch EC2 instance.

3. In this EC2 instance use the key and security group which we have created in step 1.

4. Launch one Volume (EBS) and mount that volume into /var/www/html

5. Developer have uploaded the code into github repo also the repo has some images.

6. Copy the github repo code into /var/www/html

7. Create S3 bucket, and copy/deploy the images from github repo into the s3 bucket and change the permission to public readable.

8 Create a Cloudfront using s3 bucket(which contains images) and use the Cloudfront URL to update in code in /var/www/html.
```
>Requirements

_AWS_
```
1. Create an AWS account and after logging in create an IAM account.

2. Download the AWS CLI tool and use AWS CLI for generating a profile which we would provide while running the Terraform code.
```
_Terraform_
```
1. Download terraform software and after downloading add terraform path in enviornment variables.

2. Create a folder in which our terraform code will be saved and using terraform init command download the required plugins for the providers used.
```
_Github_
```
1. Create the Github Repo which will be save our website code.
```
[Visit WebCode](https://github.com/hackcoderr/Mini-Project)


### FlowChart of Problem Statement

![images](https://github.com/hackcoderr/Mini-Project/blob/master/images/portfolio/webserver123.jpg)


### Explaination of Code
>1. Create the key pair.
```
provider "aws" {
        profile = "mickey"
        region  = "ap-south-1"
}
resource "aws_key_pair" "keypair" {
  key_name   = "Bot1"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}
```

> 2. Create a Security Group
```
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
```
> 3. Launch an EC2 instance using the pre-created Key-pair and Security Group. 
```
resource "aws_instance" "myterraformos1" {
  ami = "ami-0447a12f28fddb066"
  instance_type = "t2.micro"
  key_name = "keyname111"
  security_groups = ["allow_http"]

  connection {
     type = "ssh"
     user = "ec2-user"
     private_key = file("C:/Users/Sharma/Downloads/keyname111.pem")
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
```
>4. Launch one Volume (EBS). Attach it to the instance. Next mount that volume into /var/www/html/

>5. As soon as the developer updates something in the code in GitHub, clone this Github repo which has our website source code also has some static images(static content).Clone the GitHub repo to this location /var/www/html
```

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
    private_key = file("C:/Users/Sharma/Downloads/keyname111.pem")
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

```
> 6. Create an S3 bucket. All the static content of our web server is stored over here. Copy images from your system to S3 and change the permission to public readable.
```
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
```
> 7. Create a distribution through CloudFront and using S3 bucket generate one CloudFront URL and dynamically update this URL in website code in the “index.html” file.
```
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
```
In the end, Terraform will automatically launch our website having the latest content in the browser.

Now Our Code will be Display on the Browser using the URL.
