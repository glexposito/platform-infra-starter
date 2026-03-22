# terraform-simple

Minimal Terraform project for Azure Container Apps with a clean split between:

- shared platform resources
- app-specific resources

Terraform roots:

- `shared/`
- `app/`

Environment values:

- `env/dev.shared.tfvars`
- `env/dev.app.tfvars`
- `env/prod.shared.tfvars`
- `env/prod.app.tfvars`

Backend config:

- `backend/dev.shared.hcl`
- `backend/dev.app.hcl`
- `backend/prod.shared.hcl`
- `backend/prod.app.hcl`

The `.tfvars` files only define naming tokens such as `stack_name`, `app_name`, `environment`, and `region_code`. Resource names are generated in Terraform to match the existing pattern.

The backend `.hcl` files define where Terraform state is stored in Azure Storage.

The app `.tfvars` files also define the shared remote state lookup values used by `terraform_remote_state`.

The `shared` stack creates:

- resource group
- storage account
- Container Apps environment

The `app` stack creates:

- one Container App

`app` reads the `shared` outputs through `terraform_remote_state`, so the two states stay separate.

To keep Azure Storage Account naming valid, the shared stack uses a short fixed prefix for that resource name:

- `stplat${environment}${region_code}`

## Usage

Update the backend files with your real Terraform state storage values before running anything:

- `resource_group_name`
- `storage_account_name`
- `container_name`
- `key`

Initialize and apply shared first:

```bash
cd shared
terraform init -backend-config=../backend/dev.shared.hcl
terraform plan -var-file=../env/dev.shared.tfvars
terraform apply -var-file=../env/dev.shared.tfvars
```

Then initialize and apply app:

```bash
cd app
terraform init -backend-config=../backend/dev.app.hcl
terraform plan -var-file=../env/dev.app.tfvars
terraform apply -var-file=../env/dev.app.tfvars
```

For production, use:

- `../backend/prod.shared.hcl`
- `../backend/prod.app.hcl`
- `../env/prod.shared.tfvars`
- `../env/prod.app.tfvars`

## GitHub Actions

There are two independent manual workflows:

- `.github/workflows/deploy-shared.yml`
- `.github/workflows/deploy-app.yml`

Both workflows let you choose:

- `environment`: `dev` or `prod`
- `command`: `plan` or `apply`

The shared workflow uses the matching backend file:

- `dev` -> `backend/dev.shared.hcl`
- `prod` -> `backend/prod.shared.hcl`

The app workflow uses the matching backend file. The shared state key is defined in the app `.tfvars` file for each environment:

- `dev` -> `backend/dev.app.hcl` and `platform/dev/shared.tfstate`
- `prod` -> `backend/prod.app.hcl` and `platform/prod/shared.tfstate`

## Notes

- Backend blocks use `azurerm`.
- Update the backend `.hcl` files if your Terraform state storage values differ from this setup.
- Resource names match the existing repo naming pattern.
- This project keeps the resource definitions directly in `shared/` and `app/`, split into small files by concern to stay simple and readable.
