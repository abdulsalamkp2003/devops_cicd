output "instance_hostname" {
  description = "Private DNS name of the EC2 instance."
  value       = aws_instance.app_server.private_dns
}

# In root main.tf (or root outputs.tf):

output "practice_bucket_arn" {
  description = "The ARN of the created S3 bucket from the child module"
  value       = module.my_s3_practice.bucket_arn
}

# --- Server 2 Outputs (my_practice_ec2 module) ---
output "second_instance_id" {
  description = "The ID of the second EC2 instance."
  value       = module.my_practice_ec2.id
}