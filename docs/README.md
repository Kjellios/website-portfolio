# Documentation Overview

This folder contains implementation notes, architecture breakdowns, and security references for this repository’s infrastructure and CI/CD pipeline.

## Structure

- `infra/` – Terraform backend, IAM roles, DNS, and certificate setup
- `security/` – GitHub Actions trust policy, permissions, branch protection rules
- `ci-cd/` – GitHub Actions workflow design and deployment behavior

These files are public by design. They serve both as internal references and as a learning tool for others using Terraform + AWS + GitHub Actions.

## Purpose

- Document decisions that impact infrastructure and security
- Help others understand this setup as a real-world reference
- Provide transparency into how GitHub OIDC, IAM, and CI/CD work together

_Last updated: 2025-04-04_

<!-- Test signed commit on 2025-04-04 -->

