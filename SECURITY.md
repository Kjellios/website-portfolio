# Security Policy

This repository uses GitHub Actions, Terraform, and AWS infrastructure. Security is a core consideration throughout deployment, automation, and infrastructure management.

## Reporting a Vulnerability

If you discover a security issue, please **do not create a public issue**. Instead, contact me directly via [Kjell.Hysjulien@gmail.com](mailto:Kjell.Hysjulien@gmail.com). I will respond promptly to verify the issue and take appropriate action.

## Authentication & Secrets

- GitHub Actions uses **OIDC (OpenID Connect)** to authenticate securely with AWS. No static credentials are stored in the repository or secrets manager.
- The AWS IAM role used by GitHub Actions has a tightly scoped trust policy and permissions boundary.
- `.env`, `.tfstate`, and all sensitive files are excluded via `.gitignore`.
- Past Git history has been scrubbed using `git filter-repo` to remove any accidentally committed credentials.

## Infrastructure Security

- Terraform remote state is stored in an **S3 bucket** with **DynamoDB state locking** enabled.
- S3 buckets are configured to block public access by default. Logging buckets are segregated and monitored.
- CloudFront is used to serve static site content with HTTPS via ACM-issued TLS certificates.

## GitHub Repository Hardening

The following repository-level security features are enabled:

- GitHub Actions **OIDC-based authentication**
- Secret scanning (GitHub Advanced Security)
- Dependabot security alerts and updates
- Commit history scrubbed with `filter-repo`
- `.gitignore` configured to exclude secrets, logs, backups, and Terraform state
- Code and action workflow reviewed before being made public

## Branch Protection Rules

The `main` branch is protected using the following settings:

- Require pull requests before merging
- Require 1+ approvals
- Dismiss stale approvals on new commits
- Require passing status checks (e.g. `deploy.yml`)
- Require up-to-date branches before merging
- Require linear history
- (Optional) Require signed commits
- Include administrators in protection rules

## Additional Recommendations

This repository is public for educational and portfolio purposes only. No production credentials or data are used. Infrastructure and policies should be reviewed before reusing in a production environment.

---
Last updated: 2025-04-03

