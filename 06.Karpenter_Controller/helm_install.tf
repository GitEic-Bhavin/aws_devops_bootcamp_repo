# Login to Public ECR first

resource "null_resource" "ecr_public_login" {
  provisioner "local-exec" {
    command = <<EOT
        aws ecr-public get-login-password --region us-east-1 | \
        helm registry login -u AWS --password-stdin public.ecr.aws
        EOT
  }
}

resource "helm_release" "karpenter" {
    name = var.helm_release_name_karpenter
    repository = var.karpenter_helm_repo
    chart = var.helm_karpenter_chart
    version = var.karpenter_helm_version
    namespace = "kube-system"
    create_namespace = false

    depends_on = [ 
        null_resource.ecr_public_login,
        aws_iam_role.karpenter_controller,
        aws_iam_policy.karpenter_controller,
        aws_iam_role_policy_attachment.karpenter_controller_attach,
        aws_eks_access_entry.karpenter_node_access,
        aws_eks_pod_identity_association.karpenter,
        aws_sqs_queue.karpenter_interruption
     ]
    set = [
        {
            name = "settings.clusterName"
            value = data.terraform_remote_state.eks.outputs.eks_cluster_name
        },
        {
            name = "settings.clusterEndpoint"
            value = data.terraform_remote_state.eks.outputs.eks_cluster_endpoint
        },
        {
            name = "settings.interruptionQueue"
            value = aws_sqs_queue.karpenter_interruption.name
        },
        {
            name = "serviceAccount.name"
            value = "karpenter"
        },
        {
            name = "serviceAccount.create"
            value = "true"
        }

    ]

}      

output "karpenter_helm_release" {
  value = helm_release.karpenter.metadata
}