#!/bin/bash
set -euo pipefail
set -x

# Export Terraform variables
export TF_VAR_region="${REGION}"
export TF_VAR_vpc_id="${VPC_ID}"
export TF_VAR_cluster_name="${CLUSTER_NAME}"

# Go to Terraform directory
cd "${WORKSPACE}/DevOps_Project_3/Terraform"

# Replace cluster name safely in backend.tf
sed -i "s|ngg_cluster_name|${CLUSTER_NAME}|g" backend.tf

# Run Terraform commands
terraform init
terraform plan
terraform "${ACTION}" --auto-approve

# If action is apply
if [ "${ACTION}" = "apply" ]; then
  # Verify AWS access
  aws sts get-caller-identity

  # Configure kubectl for EKS
  aws eks update-kubeconfig --name "${CLUSTER_NAME}" --region "${REGION}"

  # Verify cluster connectivity
  kubectl get nodes

  # Add Helm repositories
  helm repo add bitnami https://charts.bitnami.com/bitnami || true
  helm repo add eks https://aws.github.io/eks-charts || true

  # Update Helm repos
  helm repo update

  # Install Nginx
  helm upgrade --install nginx bitnami/nginx

  # Install AWS Load Balancer Controller
  helm upgrade --install lb-controller eks/aws-load-balancer-controller \
    --set clusterName="${CLUSTER_NAME}"

else
  echo "Skipping Helm deployment (ACTION=${ACTION})"
fi
