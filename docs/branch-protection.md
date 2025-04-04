> This file documents the branch protection rules currently enforced on the `main` branch of this repository.
> It is intended for transparency, maintainability, and as a learning reference for DevOps best practices.


# Branch Protection Rules for `main`

This repository protects the `main` branch to prevent unintended or unauthorized changes, especially those that could trigger infrastructure deployment.

## Rule Configuration

Apply the following rules under:

GitHub → Settings → Branches → Add rule for `main`

### Required Settings

- Require a pull request before merging
  - Require at least 1 approval
  - Dismiss stale pull request approvals when new commits are pushed
- Require status checks to pass before merging
  - Require your `deploy` workflow (and any others you add later)
  - Require branches to be up to date before merging
- Require linear history
- Include administrators

### Optional Settings

- Require signed commits
- Restrict who can push to the branch (limit to GitHub Actions and your account)
- Require conversation resolution before merging

## Purpose

These settings:
- Prevent direct pushes to `main`
- Ensure all changes are reviewed, built, and tested
- Protect against accidental `terraform apply` from unverified commits

Last reviewed: 2025-04-04

