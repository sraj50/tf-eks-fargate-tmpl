terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.20.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }

    template = {
      source = "hashicorp/template"
      version = "2.2.0"
    }

    external = {
      source = "hashicorp/external"
      version = "2.1.0"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.0.1"
    }
  }

  required_version = "> 0.14"
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source             = "./vpc"
  name               = var.name
  environment        = var.environment
  cidr               = var.cidr
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  availability_zones = var.availability_zones
}

module "eks" {
  source          = "./eks"
  name            = var.name
  environment     = var.environment
  region          = var.region
  k8s_version     = var.k8s_version
  vpc_id          = module.vpc.id
  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets
  kubeconfig_path = var.kubeconfig_path
}

module "ingress" {
  source       = "./ingress"
  name         = var.name
  environment  = var.environment
  region       = var.region
  vpc_id       = module.vpc.id
  cluster_id   = module.eks.cluster_id
}
