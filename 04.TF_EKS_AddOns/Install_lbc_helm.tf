# A Release is an instance of a chart running in a Kubernetes cluster.

# helm_release describes the desired status of a chart in a kubernetes cluster.

resource "helm_release" "lbc_controller" {
  name = "aws-load-balancer-controller" # Release name
  namespace = "kube-system"
  chart = "aws-load-balancer-controller" # chart name
  repository = "https://aws.github.io/eks-charts"

  depends_on = [ 
    aws_eks_node_group.pvt_nodes,
    aws_iam_role.lbc_role,
    aws_eks_pod_identity_association.lbc,
    aws_eks_addon.pia
   ]

    wait = true
    timeout = 600
    cleanup_on_fail = true

# By set you can pass your custom required value to helm install, upgrade
    set = [ 
        {
            name = "clusterName"
            value = "${aws_eks_cluster.main.name}"
        },
        {
            name = "region"
            value = "${var.aws_region}"
        },
        {
            name = "vpcId"
            value = "${data.terraform_remote_state.vpc.outputs.vpc_id}"
        },
        {
            name = "serviceAccount.create"
            value = "true"
        },
        {
            name = "serviceAccount.name"
            value = "aws-load-balancer-controller-sa"
        }
    ]
}

output "helm_lbc_metadata" {
  value = helm_release.lbc_controller.metadata
}