# Specify the AWS region
variable "aws_region" {
  description = "AWS region to deploy resources in"
  default     = "ap-south-1"  # Update this if necessary
}

# Update kubeconfig for EKS cluster to allow kubectl commands to work
resource "null_resource" "update_kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region}"
  }

  # Only trigger this resource when the EKS cluster is created or updated
  depends_on = [module.eks]
}

# Execute Ansible Playbook to deploy microservices to EKS
resource "null_resource" "deploy_microservices" {
  provisioner "local-exec" {
    command = "ansible-playbook /home/farhu/terraform/tf-ans-k8s/ansible/deploy-to-eks.yaml"
    environment = {
      KUBECONFIG = "${path.module}/kubeconfig"  # Explicit kubeconfig path for Ansible
    }
  }

  # Ensure the playbook is run after the kubeconfig update
  depends_on = [null_resource.update_kubeconfig]
}

# Output cluster information if desired
output "cluster_name" {
  value       = module.eks.cluster_name
  description = "The name of the EKS cluster"
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "The endpoint of the EKS cluster"
}
