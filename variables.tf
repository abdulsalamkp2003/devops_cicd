variable "instance_name" {
  description = "Value of the EC2 instance's Name tag."
  type        = string
  default     = "learn-terraform"
}

variable "instance_tag" {
  description = "Value of the EC2 instance new tag."
  type        = string
  default     = "ConsoleEdited"
}

variable "instance_type" {
  description = "The EC2 instance's type."
  type        = string
  default     = "t2.micro"
}

variable "name" {
  type    = string
  default = "my-practice-ec2"
}

variable "ami" {
  type        = string
  description = "AMI ID for the EC2 instance"
  default     = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}

