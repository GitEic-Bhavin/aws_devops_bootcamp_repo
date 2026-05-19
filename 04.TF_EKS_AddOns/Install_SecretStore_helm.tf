resource "helm_release" "secrets_store_csi_driver" {
  depends_on = [ 
    aws_eks_addon.pia,
    aws_eks_node_group.pvt_nodes
   ]

   name = "csi-screts-store"
   repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
   chart = "secrets-store-csi-driver"
   namespace = "kube-system"

    set = [
        {
            name = "syncSecret.enabled"
            value = "true"
        },
        {
            name = "tokenRequests[0].audience"
            value = "pods.eks.amazonaws.com"
        },

        
    ]

    wait = true
    timeout = 600
    cleanup_on_fail = true

}

output "helm_secrets_store_csi_driver_metadata" {
  value = helm_release.secrets_store_csi_driver.metadata
}