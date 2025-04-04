> This document explains how the Terraform remote backend is configured using S3 and DynamoDB.  
> It serves as a reference for securely managing Terraform state and avoiding concurrent apply operations.


# Terraform Remote Backend Setup

This project uses an S3 bucket with DynamoDB state locking to manage the remote Terraform backend securely and reliably.

## Overview

- **Backend type**: `s3`
- **Region**: `us-east-1`
- **State bucket**: `kjellhysjulien.com`
- **Lock table**: `terraform-locks`
- **State file path**: `terraform.tfstate`
- **Encryption**: Enabled (AES256 via S3 default encryption)
- **Authentication**: GitHub OIDC with IAM Role (`GitHubActionsOIDCRole`)

## Bucket Requirements

Your `kjellhysjulien.com` S3 bucket must:

- Be private (no public access via policy or ACLs)
- Allow access from CloudFront OAC for site content
- Store Terraform state under a specific key (e.g. `terraform.tfstate`)
- Be versioned (recommended for state recovery)
- Be encrypted at rest

### Bucket Policy (Example)

If using this bucket **only** for Terraform, restrict access to the IAM role you use locally and/or in CI/CD.  
Since you're using it for both Terraform and public website files, apply **fine-grained IAM policies**, not broad bucket policies.

## DynamoDB Table

- **Name**: `terraform-locks`
- **Partition Key**: `LockID` (String)
- **Billing Mode**: `PAY_PER_REQUEST`
- **Purpose**: Prevent concurrent `terraform apply` operations

## Terraform Backend Configuration (backend-setup.tf)

```hcl
terraform {
  backend "s3" {
    bucket         = "kjellhysjulien.com"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

## Setup Instructions

1. **Create the bucket and DynamoDB table** if they don't exist.
   You can use Terraform to provision them (preferred), or create manually via the AWS Console.

2. **Enable versioning** on the S3 bucket (recommended).

3. **Add `backend-setup.tf`** (see above) with your backend block.

4. **Reinitialize Terraform** to migrate local state to remote:
   ```bash
   terraform init -migrate-state
   ```

   > If your state is already remote, this will safely confirm the backend connection.

## Security Considerations

- Do **not** expose the S3 bucket to public access.
- Restrict all Terraform access via IAM roles (e.g. your GitHub OIDC role).
- Avoid storing credentials locally; use `aws-vault`, SSO, or OIDC for authentication.

## Notes

- This repo excludes `*.tfstate`, `.terraform/`, and `.env` from Git via `.gitignore`.
- To inspect state remotely, use:
  ```bash
  terraform state list
  terraform state show <resource>
  ```

Last reviewed: 2025-04-04