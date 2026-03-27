# terraform-simple

Minimal Terraform project for a single Azure deployment that creates:

- resource group
- Azure Container Instance group

Terraform root:

- repository root

Reusable module:

- `modules/aci/`

Environment values:

- `env/dev/deploy.tfvars`
- `env/prod/deploy.tfvars`

Backend config:

- `backend/dev.tfbackend`
- `backend/prod.tfbackend`

The `.tfvars` files define naming tokens such as `stack_name`, `app_name`, `environment`, and `region_code`, plus the container settings. Resource names are generated in Terraform to match the repo naming pattern.

The backend `.tfbackend` files define where Terraform state is stored in Azure Storage.

Optional Key Vault support is included for an existing Key Vault:

- set `key_vault_id` to grant `Key Vault Secrets User` on that vault
- use `key_vault_secret_environment_variables` to map container env var names to Key Vault secret names
- leave `key_vault_id = null` to skip Key Vault integration entirely

ACI can accept `secure_environment_variables`. This repo can also read secrets from Key Vault during Terraform apply and inject them into the container as secure environment variables.

Note: if Terraform reads a Key Vault secret and injects it into the container, that secret value will be handled by Terraform and may be present in Terraform state. If you want to avoid that, grant the container identity access to Key Vault and fetch the secret from the application at runtime instead.

Example:

```hcl
key_vault_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.KeyVault/vaults/<vault-name>"

key_vault_secret_environment_variables = {
  API_TOKEN = "api-token"
}
```

## Usage

Update the backend files with your real Terraform state storage values before running anything:

- `resource_group_name`
- `storage_account_name`
- `container_name`
- `key`

Initialize and apply for `dev`:

```bash
terraform init -backend-config=backend/dev.tfbackend
terraform plan -var-file=env/dev/deploy.tfvars
terraform apply -var-file=env/dev/deploy.tfvars
```

For production, use:

- `backend/prod.tfbackend`
- `env/prod/deploy.tfvars`

## GitHub Actions

There is one manual workflow:

- `.github/workflows/deploy.yml`

It lets you choose:

- `environment`: `dev` or `prod`
- `command`: `plan` or `apply`

It uses the matching backend and tfvars files:

- `dev` -> `backend/dev.tfbackend` and `env/dev/deploy.tfvars`
- `prod` -> `backend/prod.tfbackend` and `env/prod/deploy.tfvars`

## Notes

- Backend blocks use `azurerm`.
- Update the backend `.tfbackend` files if your Terraform state storage values differ from this setup.
- Resource names match the existing repo naming pattern.
- The root configuration stays small, while `modules/aci/` keeps the ACI resource reusable.
