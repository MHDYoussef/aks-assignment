include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/aks"
}

inputs = {
  cluster_name = "prod-aks-cluster"
  location     = "eastus"
  environment  = "prod"
}
