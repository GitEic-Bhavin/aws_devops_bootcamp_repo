aws_region = "ap-south-1"

environment_name = "test"

tags = {
    Department   = "PES_IA"
    Owner        = "bhavin.bhavsar@einfochips.com"
    End_Date     = "4 May 2026"
    Project_Name = "EIC_Internal"
    DM = "Sachin.Shah1@einfochips.com"
}

helm_karpenter_chart = "karpenter"
helm_release_name_karpenter = "karpenter"
karpenter_helm_repo = "oci://public.ecr.aws/karpenter"
karpenter_helm_version = "1.8.2"