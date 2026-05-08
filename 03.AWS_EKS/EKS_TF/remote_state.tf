# Define Remote state backend here

data "terraform_remote_state" "vpc" {
    backend = "s3"

    config = {
        bucket       = "bhavindemo-s3-tfstate-test-qde617"
        key          = "test/terraform.tfstate"
        region       = "ap-south-1"
    }
}

output "vpc_id" {
  value = data.terraform_remote_state.vpc.outputs.vpc_id
}

output "pvt_sub_id" {
  value = data.terraform_remote_state.vpc.outputs.pvt_sub_id
}

output "pub_sub_id" {
  value = data.terraform_remote_state.vpc.outputs.pub_sub_id
}