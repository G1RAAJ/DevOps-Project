#!/bin/bash
set -euo pipefail
set -x

export TF_VAR_region="${REGION}"
export TF_VAR_vpc_id="${VPC_ID}"
export TF_VAR_cluster_name="${CLUSTER_NAME}"

cd ${WORKSPACE}/DevOps_Project_3/Terraform

terraform init -upgrade
terraform plan
terraform ${ACTION} -auto-approve

if [ "${ACTION}" = "apply" ]; then

  aws eks update-kubeconfig --name ${CLUSTER_NAME} --region ${REGION}

  kubectl get nodes

  helm repo add bitnami https://charts.bitnami.com/bitnami || true
  helm repo update

  kubectl create namespace nginx || true

  helm upgrade --install nginx bitnami/nginx -n nginx

  kubectl get svc -n nginx

else
  echo "Destroy completed"
fi
