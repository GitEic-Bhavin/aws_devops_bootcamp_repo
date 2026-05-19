resource "helm_release" "aws_secrets_provider" {
  depends_on = [ 
    aws_eks_addon.pia,
    aws_eks_node_group.pvt_nodes,
    helm_release.secrets_store_csi_driver
   ]

   name = "secrets-provider-aws"
   repository = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
   chart =  "secrets-store-csi-driver-provider-aws"
   namespace = "kube-system"

   set = [
        {
            name = "secrets-store-csi-driver.install"
            value = "false"
        }
    ]    

    wait = true
    timeout = 600

    cleanup_on_fail = true
}