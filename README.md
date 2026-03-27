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

Private ACR images are supported with a managed identity:

```hcl
acr_name                = "<acr-name>"
acr_resource_group_name = "<resource-group>"
container_image_repository = "myapp"
container_image_tag        = "latest"
```

When `acr_name` is set, this repository looks up the registry, derives the login server automatically, builds the full image reference from `container_image_repository` and `container_image_tag`, creates a user-assigned identity, grants it `AcrPull` on the registry, waits briefly for RBAC propagation, and configures ACI to use that identity for the image pull. If `acr_name` is null, set `container_image` directly for a public image instead.

Optional Key Vault support is included for an existing Key Vault:

- set `key_vault_name` and `key_vault_resource_group_name` so Terraform can look up that vault
- use `key_vault_secret_environment_variables` to map container env var names to Key Vault secret names
- leave `key_vault_name = null` to skip Key Vault integration entirely

ACI can accept `secure_environment_variables`. This repo can also read secrets from Key Vault during Terraform apply and inject them into the container as secure environment variables.

Note: if Terraform reads a Key Vault secret and injects it into the container, that secret value will be handled by Terraform and may be present in Terraform state. If you want to avoid that, grant the container identity access to Key Vault and fetch the secret from the application at runtime instead.

Example:

```hcl
key_vault_name                = "<vault-name>"
key_vault_resource_group_name = "<resource-group>"

key_vault_secret_environment_variables = {
  API_TOKEN = "api-token"
}
```

If Terraform reads a secret from Key Vault during `plan` or `apply`, the identity running Terraform also needs Key Vault data-plane access. In GitHub Actions, that means the GitHub OIDC application must have a role such as `Key Vault Secrets User` on the vault.

Why this is needed:

- `data.azurerm_key_vault_secret` is executed by Terraform during `plan` and `apply`
- in this repository, Terraform runs as the GitHub Actions OIDC identity
- the ACI managed identity does not exist until deployment time, so it cannot help Terraform read the secret earlier
- because of that, the GitHub OIDC identity must be allowed to read the Key Vault secret if Terraform is the component injecting it into the container environment

If you also want Terraform to create Azure RBAC role assignments, the GitHub OIDC identity needs RBAC-management permission as well, such as `Owner` or `User Access Administrator` at the relevant scope. This is separate from secret-read access. Being `Owner` helps Terraform create role assignments, but Key Vault secret reads still rely on Key Vault data-plane authorization being effective for the identity running Terraform.

Example:

```bash
az role assignment create \
  --assignee "<AZURE_CLIENT_ID>" \
  --role "Key Vault Secrets User" \
  --scope "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.KeyVault/vaults/<vault-name>"
```

This is separate from any access your application might need at runtime:

- GitHub OIDC identity: needed so Terraform can read the secret during `plan` and `apply`
- GitHub OIDC identity: also needs `Owner` or `User Access Administrator` if Terraform should create RBAC assignments for the ACI managed identity
- ACI managed identity: needs `Key Vault Secrets User` if the deployed container should read from Key Vault at runtime

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
