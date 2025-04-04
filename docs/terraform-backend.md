# Terraform Backend Configuration

This project uses a remote backend to store Terraform state in Amazon S3 with state locking provided by DynamoDB. This ensures that state is persisted reliably across runs and is protected from concurrent access.

## Purpose

- **S3** stores the state file (`terraform.tfstate`)
- **DynamoDB** provides state locking to prevent concurrent `apply` runs
- This setup supports collaboration, disaster recovery, and CI/CD automation

## Backend Block

Terraform's backend block is configured in a separate file: `backend-setup.tf`.

```hcl
terraform {
  backend "s3" {
    bucket         = "<bucket-name>"
    key            = "<state-path>/terraform.tfstate"
    region         = "<region>"
    dynamodb_table = "<lock-table-name>"
    encrypt        = true
  }
}
```

## Field Breakdown

| Field           | Description                                               |
|----------------|-----------------------------------------------------------|
| `bucket`        | S3 bucket used to store the Terraform state file         |
| `key`           | Path inside the bucket where the state file is stored    |
| `region`        | AWS region where the bucket and DynamoDB table reside    |
| `dynamodb_table`| Name of the DynamoDB table used for state locking        |
| `encrypt`       | Ensures the state file is encrypted at rest in S3        |

## Deployment Order

The backend must exist before Terraform can be initialized.

If you're bootstrapping this from scratch:

1. Create the S3 bucket (private, versioned, encrypted)
2. Create the DynamoDB table with:
   - `Partition key`: `LockID` (string)
   - On-demand or provisioned capacity
3. Ensure both are in the same AWS region

Once created, run:

```bash
terraform init
```

Terraform will connect to the backend and pull the latest state.

## Notes

- The backend itself is not managed by Terraform. It must be created manually or through a separate bootstrap script.
- Bucket versioning and server-side encryption should be enabled.
- Public access should be blocked at the bucket level.
- This backend is dedicated to this project and not shared across other modules or repositories.

Last reviewed: 2025-04-03

