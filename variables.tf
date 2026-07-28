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
  description = "Name tag for the instance"
  type        = string
}

variable "ami" {
  description = "AMI ID for the instance"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "Subnet ID where the instance will be launched"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
