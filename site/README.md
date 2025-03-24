# Personal Website: kjellhysjulien.com

This project hosts the static content for my personal website, deployed on AWS using Terraform.

## Overview

The site is designed as a professional and educational hub, showcasing:
- My resume and background
- AWS/cloud-focused learning notes
- A custom study guide for the AWS Certified Solutions Architect – Associate exam

## Infrastructure

Built using the following AWS services:
- **S3** (for private file storage, served via CloudFront)
- **CloudFront** (CDN for HTTPS delivery and caching)
- **Route 53** (DNS management)
- **ACM** (SSL certificates for HTTPS)
- **Terraform** (infrastructure as code)

## Key Details

- **Primary domain**: https://kjellhysjulien.com  
- **Subdomain redirect**: https://www.kjellhysjulien.com → root domain  
- **HTTPS** enforced via CloudFront with an ACM certificate  
- **Logging** enabled via S3  
- **Static content** is uploaded to a private S3 bucket and served securely through CloudFront.

## Deployment Notes

- All infrastructure is defined in `main.tf`
- Uses Terraform’s `aws` provider (region: `us-east-1`)
- CloudFront cache may need manual invalidation when updating content
- IAM access and permissions tightly scoped for security