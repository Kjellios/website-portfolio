> This document explains the GitHub Actions security model used in this repository, including OIDC authentication, IAM permissions, and workflow hardening.  
> It’s designed for transparency, security review, and as a learning reference for secure CI/CD with GitHub and AWS.


# GitHub Actions Security and Permissions

This repository uses GitHub Actions to deploy infrastructure and static site content to AWS. This document outlines the security practices and permissions applied to those workflows.

## Workflow File

Path: `.github/workflows/deploy.yml`

## OIDC Authentication

GitHub Actions uses OpenID Connect (OIDC) to assume an IAM role in AWS. No long-lived AWS credentials are stored in GitHub Secrets.

The IAM trust relationship is scoped to:
- Specific GitHub organization and repository
- Specific branch (`ref`)
- (Optional) Specific workflow via `workflow` claim

## IAM Permissions

The IAM role used by GitHub Actions has minimal privileges. It is scoped to allow:
- Terraform actions on specific AWS resources
- S3 object syncing
- CloudFront cache invalidation

All permissions are least-privilege and tied to GitHub OIDC federation.

## GitHub Actions Workflow Security

- `permissions:` is explicitly set to:
  ```yaml
  permissions:
    id-token: write     # Required for OIDC
    contents: read      # Required to fetch code
  ```
- Triggers are locked down:
  ```yaml
  on:
    push:
      branches:
        - main
    workflow_dispatch:
  ```

- No use of `pull_request_target` (avoids exposure to forks)
- All action versions are pinned to specific releases, not floating tags

Example:
```yaml
- uses: actions/checkout@v2.5.0
```

## Recommendations

- Add a secondary workflow to run `terraform fmt`, `validate`, `tflint`, or `checkov`
- Avoid using GitHub Secrets for AWS keys; rely exclusively on OIDC
- Maintain strict branch protection to ensure workflows are only triggered by reviewed changes

## Summary

| Area                     | Status                      |
|--------------------------|-----------------------------|
| OIDC Enabled             | Yes                         |
| Least-Privilege IAM Role | Yes                         |
| Workflow Triggers Scoped | Yes                         |
| Minimal Permissions Set  | Yes                         |
| Actions Pinned           | Yes                         |
| Secrets Avoided          | Yes                         |

Last reviewed: 2025-04-04