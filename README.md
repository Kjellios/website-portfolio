# Portfolio Infrastructure

This repository manages the infrastructure for [kjellhysjulien.com](https://kjellhysjulien.com) using Terraform, AWS, and GitHub Actions with OIDC authentication.

## Overview

- **Cloud provider**: AWS
- **Infrastructure as Code**: Terraform
- **CI/CD**: GitHub Actions with OpenID Connect (OIDC)
- **Hosting**: S3 (static site) + CloudFront (CDN)
- **DNS**: Route 53
- **TLS**: ACM-managed certificates
- **Logging**: Centralized S3 log bucket
- **Security**: No long-lived AWS keys; GitHub OIDC used for auth

## Workflow Summary

- GitHub Actions deploys the `site/` directory to the S3 bucket.
- CloudFront cache is invalidated after each deploy.
- Terraform manages all AWS infrastructure.
- Remote state is stored in an S3 bucket with DynamoDB locking.

## Folder Structure

```
.
├── site/                     # Static site files (Miniport HTML5 template)
├── *.tf                     # Terraform configuration split by resource
├── .github/workflows/       # GitHub Actions workflows (OIDC deploy)
├── _backups/                # Local backups (excluded from Git)
└── .terraform.lock.hcl      # Provider version lock file
```

## Usage

### Requirements

- Terraform installed
- GitHub OIDC role properly configured in AWS
- AWS S3 + DynamoDB backend already bootstrapped

### Terraform Workflow

```bash
terraform init
terraform plan
terraform apply
```

### GitHub Actions Deploy

Triggered automatically on push to `main`. It:
1. Assumes an IAM role via OIDC
2. Syncs `site/` to the S3 bucket
3. Invalidates CloudFront cache

## Security Notes

- `.env`, `.tfstate`, and secrets are excluded via `.gitignore`
- GitHub OIDC used for secure auth — no static AWS credentials
- This repo has been scrubbed to remove secrets from Git history

## Additional Documentation

See [docs/README.md](docs/README.md) for internal notes on infrastructure setup, IAM roles, CI/CD design, and GitHub Actions hardening.

## License

[MIT](./site/LICENSE.txt)

