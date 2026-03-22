# terraform-simple

Minimal Terraform project for Azure Container Apps with a clean split between:

- platform resources
- container app resources

Terraform roots:

- `platform/`
- `container-app/`

Environment values:

- `env/dev/platform.tfvars`
- `env/dev/container-app.tfvars`
- `env/prod/platform.tfvars`
- `env/prod/container-app.tfvars`

Backend config:

- `backend/dev.platform.hcl`
- `backend/dev.container-app.hcl`
- `backend/prod.platform.hcl`
- `backend/prod.container-app.hcl`

The `.tfvars` files only define naming tokens such as `stack_name`, `app_name`, `environment`, and `region_code`. Resource names are generated in Terraform to match the existing pattern.

The backend `.hcl` files define where Terraform state is stored in Azure Storage.

The container app `.tfvars` files also define the platform remote state lookup object used by `terraform_remote_state`.

Example:

```hcl
platform_state = {
  resource_group_name  = "rg-aca-terraform-state"
  storage_account_name = "acainfratfstate01"
  container_name       = "tfstate"
  key                  = "platform/dev/platform.tfstate"
}
```

The `platform` stack creates:

- resource group
- storage account
- Container Apps environment

The `container-app` stack creates:

- one Container App

`container-app` reads the `platform` outputs through `terraform_remote_state`, so the two states stay separate.

Optional Key Vault support is included for container app secrets:

- set `secret_environment_variables` with `key_vault_secret_id`
- set `key_vault_id` to grant the Container App identity `Key Vault Secrets User` on that vault
- leave `key_vault_id = null` to skip Key Vault RBAC entirely

Example:

```hcl
key_vault_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.KeyVault/vaults/<vault-name>"

secret_environment_variables = {
  API_KEY = {
    secret_name         = "api-key"
    key_vault_secret_id = "https://<vault-name>.vault.azure.net/secrets/api-key"
  }
}
```

To keep Azure Storage Account naming valid, the platform stack uses a short fixed prefix for that resource name:

- `stplat${environment}${region_code}`

## Usage

Update the backend files with your real Terraform state storage values before running anything:

- `resource_group_name`
- `storage_account_name`
- `container_name`
- `key`

Initialize and apply platform first:

```bash
cd platform
terraform init -backend-config=../backend/dev.platform.hcl
terraform plan -var-file=../env/dev/platform.tfvars
terraform apply -var-file=../env/dev/platform.tfvars
```

Then initialize and apply container app:

```bash
cd container-app
terraform init -backend-config=../backend/dev.container-app.hcl
terraform plan -var-file=../env/dev/container-app.tfvars
terraform apply -var-file=../env/dev/container-app.tfvars
```

For production, use:

- `../backend/prod.platform.hcl`
- `../backend/prod.container-app.hcl`
- `../env/prod/platform.tfvars`
- `../env/prod/container-app.tfvars`

## GitHub Actions

There are two independent manual workflows:

- `.github/workflows/deploy-platform.yml`
- `.github/workflows/deploy-container-app.yml`

Both workflows let you choose:

- `environment`: `dev` or `prod`
- `command`: `plan` or `apply`

The platform workflow uses the matching backend file:

- `dev` -> `backend/dev.platform.hcl`
- `prod` -> `backend/prod.platform.hcl`

The container app workflow uses the matching backend file. The platform remote state lookup is defined in the container app `.tfvars` file for each environment:

- `dev` -> `backend/dev.container-app.hcl` and `platform/dev/platform.tfstate`
- `prod` -> `backend/prod.container-app.hcl` and `platform/prod/platform.tfstate`

## Notes

- Backend blocks use `azurerm`.
- Update the backend `.hcl` files if your Terraform state storage values differ from this setup.
- Resource names match the existing repo naming pattern.
- This project keeps the resource definitions directly in `platform/` and `container-app/`, split into small files by concern to stay simple and readable.
