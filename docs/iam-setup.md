# GitHub OIDC Role: `GitHubActionsOIDCRole`

This role is assumed by GitHub Actions workflows using OpenID Connect (OIDC) for secure, short-lived access to AWS resources. It is used for infrastructure deployment and S3 + CloudFront updates.

---

## Trust Relationship

This IAM role uses a trust policy that allows GitHub’s OIDC provider to assume the role from a specific repository and branch.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<account-id>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:<github-username>/<repo-name>:ref:refs/heads/main"
        }
      }
    }
  ]
}
```

### OIDC Conditions

| Claim                                | Description                                      |
|-------------------------------------|--------------------------------------------------|
| `aud = sts.amazonaws.com`           | Ensures token is intended for AWS STS           |
| `sub = repo:<user>/<repo>:ref:...` | Locks access to a specific GitHub repo + branch |

This ensures that only workflows from the intended GitHub repo and branch can assume the role.

---

## Attached Policy: `WebsiteDeployPolicy`

This role uses a scoped customer-managed policy that permits deployment to S3 and CloudFront:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::<your-site-bucket>",
        "arn:aws:s3:::<your-site-bucket>/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudfront:CreateInvalidation"
      ],
      "Resource": "arn:aws:cloudfront::<account-id>:distribution/<distribution-id>"
    }
  ]
}
```

### Notes

- S3 access is scoped to the site bucket only
- CloudFront invalidation is limited to the single distribution used by the site
- No wildcard access is granted beyond this resource scope

---

## Summary

| Item                     | Value                                             |
|--------------------------|---------------------------------------------------|
| Role name                | `GitHubActionsOIDCRole`                          |
| Trust provider           | `token.actions.githubusercontent.com` OIDC       |
| GitHub repo bound        | `repo:<user>/<repo>:ref:refs/heads/main`        |
| Permissions scope        | Limited to S3 + CloudFront for deploy only       |
| Secrets used             | None – authentication is token-based (OIDC)      |

Last reviewed: 2025-04-03

