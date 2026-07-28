provider "aws" {
  region = "us-west-2"
}

# S3 Bucket for state storage
resource "aws_s3_bucket" "tf_state" {
  bucket        = "abdul-tf-state-storage-2026"
  force_destroy = false
}

# Enable versioning on state bucket (Critical for backups)
resource "aws_s3_bucket_versioning" "tf_state_versioning" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "tf_locks" {
  name         = "terraform-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  required_version = ">= 1.0"

  backend "s3" {
    bucket       = "abdul-tf-state-storage-2026"
    key          = "global/s3/terraform.tfstate"
    region       = "us-west-2"
    use_lockfile = true
    encrypt      = true
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  vpc_security_group_ids = [module.vpc.default_security_group_id]
  subnet_id              = module.vpc.private_subnets[0]

  tags = {
    Name            = var.instance_name
    ManualChangeEC2 = var.instance_tag

  }
}

# Call your child module sitting in modules/aws-s3-bucket
module "my_s3_practice" {
  source      = "./modules/aws-s3-bucket"
  bucket_name = "abdul-unique-practice-bucket-2026"
  environment = "practice"
}

# Automatically fetch the latest official Amazon Linux 2023 AMI for your current region
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Call the cloned EC2 module from your local folder
module "my_practice_ec2" {
  source = "./modules/ec2-instance"

  name          = var.name
  ami           = var.ami
  instance_type = var.instance_type

  # Dynamically fetch the first public subnet ID created by the VPC module!
  subnet_id = module.vpc.public_subnets[0]

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
  # Explicit dependency: Force this module to wait until app_server is fully created
  depends_on = [
    aws_instance.app_server
  ]
}
