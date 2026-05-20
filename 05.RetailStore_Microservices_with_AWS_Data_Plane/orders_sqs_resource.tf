# Orders DB talks to AWS RDS PSQL DB , AWS Secrets Manager and also to AWS SQS Queue.

# We have setup for EKS Pods Orders to AWS RDS PSQL DB and AWS Secrets Manager.

# Now we will setup AWS SQS Queue

# Let's create AWS SQS Queue

resource "aws_sqs_queue" "orders_sqs" {
    name = "${local.eks_cluster_name}-sqs-queue"
    message_retention_seconds = 86400 # 1 Days in a seconds
    delay_seconds = 0
    receive_wait_time_seconds = 10
    visibility_timeout_seconds = 30

    tags = var.tags
}

output "orders_sqs_url" {
  value = aws_sqs_queue.orders_sqs.url
}

output "orders_sqs_arn" {
  value = aws_sqs_queue.orders_sqs.arn
}