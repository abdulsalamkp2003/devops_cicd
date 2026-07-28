output "bucket_arn" {
  value       = aws_s3_bucket.this.arn
  description = "ARN of the created S3 bucket"
}