# Create IAM Trust Policy which will used by all eks resources like LoadBalancerController, Secrets Manager etc

# Generates an IAM policy document in JSON format for use with resources that expect policy documents such as aws_iam_policy.
data "aws_iam_policy_document" "assume_role" {
    statement {
      effect = "Allow"

      principals {
        type = "Service"
        identifiers = ["pods.eks.amazonaws.com"]
      }

      actions = [
        "sts:AssumeRole",
        "sts:TagSession"
      ]
    }
}