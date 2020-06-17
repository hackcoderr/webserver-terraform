## Launching-Webserver-on-AWS-cloud-using-Terraform
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
ImagesImages
![images](https://github.com/hackcoderr/Mini-Project/blob/master/images/portfolio/webserver123.jpg)
![images]()
