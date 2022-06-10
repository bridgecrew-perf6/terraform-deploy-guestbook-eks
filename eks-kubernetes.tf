terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.20.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.1"
    }
  }
}

#data "terraform_remote_state" "eks" {
 # backend = "local"

 #config = {
 #  path = "../terraform-aws-eks-workshop/src/terraform.tfstate"   
 #}
#}

data "tfe_outputs" "eks" {
    organization = "cxpm-training"
    workspace = var.eks_cluster_workspace_name
}

# Retrieve EKS cluster information
provider "aws" {
  #region = data.terraform_remote_state.eks.outputs.region
  region = data.tfe_outputs.eks.values.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

data "aws_eks_cluster" "cluster" {
  #name = data.terraform_remote_state.eks.outputs.cluster_id
  name = data.tfe_outputs.eks.values.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  #name = data.terraform_remote_state.eks.outputs.cluster_id
  name = data.tfe_outputs.eks.values.cluster_id
}



provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
