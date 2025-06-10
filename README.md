# aks-assignment

## Features

- Private AKS cluster (no public API)
- Azure AD integration via workload identity
- Managed identity for secure access to Azure resources
- RBAC enabled
- Terragrunt for multi-env support

## Prerequisites

- Azure CLI
- Terraform ≥ 1.3
- Terragrunt ≥ 0.45
- Logged into Azure: `az login`

## Setup Instructions

1. Clone the repo 
2. Configure backend (Azure blob or local)
3. Navigate to `environnments/dev/` and run:
   ```bash
   terragrunt run-all init
   terragrunt run-all plan
   terragrunt run-all apply

## Sample Plan Output (Optional)

If you want to generate a dry run:

```bash
cd environnments/dev
terragrunt run-all plan > sample-plan-output.txt