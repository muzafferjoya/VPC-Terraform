output "public_subnet_ids" {
  description = "IDs of the public subnets from the VPC module"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets from the VPC module"
  value       = module.vpc.private_subnet_ids
}

output "vpc_id" {
  description = "ID of the VPC from the VPC module"
  value       = module.vpc.vpc_id
}

