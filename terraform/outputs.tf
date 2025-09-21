output "cluster_name" {
value = module.eks.cluster_id
}
output "cluster_endpoint" {
value = module.eks.cluster_endpoint
}
output "kubeconfig_certificate_authority_data" {
value = module.eks.cluster_certificate_authority_data
}
output "ecr_repo_url" {
value = aws_ecr_repository.app_repo.repository_url
}