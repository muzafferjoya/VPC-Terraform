module "vpc" {
  source                   = "./modules/vpc"
  vpc_cidr                = "10.0.0.0/16"
  public_subnet_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidr_blocks = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones      = ["us-east-2a", "us-east-2b"]
}
