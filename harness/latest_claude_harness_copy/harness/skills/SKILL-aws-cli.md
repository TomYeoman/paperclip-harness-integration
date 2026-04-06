# SKILL: AWS CLI

Use the AWS CLI to investigate production infrastructure — IAM roles, S3 buckets, DynamoDB tables, and resource existence checks.

## Prerequisites

- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed
- Named profiles configured in `~/.aws/config` (see team-specific setup below)

## Authentication

```bash
# Log in via SSO (opens browser — one-time per session)
aws sso login --profile <profile-name>

# Verify auth
aws sts get-caller-identity --profile <profile-name>
```

Token lifetime: ~8 hours. Re-run `aws sso login` if you get `ExpiredTokenException`.

## Common Investigation Commands

### S3

```bash
# Check if a bucket exists (returns metadata if it does; 404 if not)
aws s3api head-bucket --bucket <bucket-name> --profile <profile-name>

# NOTE: AWS returns AccessDenied (not 404) for non-existent buckets when you lack s3:ListBucket.
# Use head-bucket to distinguish missing vs permission-denied — if head-bucket returns BucketRegion,
# the bucket exists and the issue is IAM permissions, not a missing bucket.

# List objects in a bucket path
aws s3 ls s3://<bucket-name>/<prefix>/ --profile <profile-name>

# Download an object
aws s3 cp s3://<bucket-name>/<key> /tmp/output.json --profile <profile-name>
```

### IAM

```bash
# List policies attached to a service role
aws iam list-attached-role-policies --role-name <service-name> --profile <profile-name>

# List inline policies
aws iam list-role-policies --role-name <service-name> --profile <profile-name>
```

Note: Reading policy documents (`iam:GetPolicy`, `iam:GetPolicyVersion`) may not be available in the developer SSO role.

### DynamoDB

```bash
# List tables
aws dynamodb list-tables --region <region> --profile <profile-name>

# Describe a table
aws dynamodb describe-table --table-name <table-name> --region <region> --profile <profile-name>
```

## Gotchas

| Symptom | Cause | Fix |
|---------|-------|-----|
| `ExpiredTokenException` | SSO token expired (8h lifetime) | Re-run `aws sso login --profile <profile>` |
| `AccessDenied` on `s3api head-bucket` | Bucket exists but no s3:ListBucket | IAM permissions issue — not a missing bucket |
| `404 Not Found` on `s3api head-bucket` | Bucket genuinely does not exist | Confirm bucket name |
| `AccessDenied` on `iam:GetPolicy` | Developer SSO role lacks IAM read | Expected — use logs + git history to infer policy state |
| `NoCredentialProviders` | Not logged in | Run `aws sso login --profile <profile>` |

---

## JetConnect Setup

### Profiles

JetConnect uses AWS SSO via `https://acas.awsapps.com/start`. Two profiles are needed:

```ini
[profile flyt-staging]
sso_start_url = https://acas.awsapps.com/start
sso_region = eu-west-1
sso_account_id = 364123201955
sso_role_name = jetc-developer
region = eu-west-1

[profile flyt-production]
sso_start_url = https://acas.awsapps.com/start
sso_region = eu-west-1
sso_account_id = 470025225193
sso_role_name = jetc-developer
region = eu-west-1
```

**Setup check:** verify these profiles exist before using this skill:
```bash
grep -l "flyt-staging\|flyt-production" ~/.aws/config && echo "profiles found" || echo "profiles missing — see setup below"
```

If missing, append the profiles above to `~/.aws/config`, or ask the agent to do it:
```bash
cat >> ~/.aws/config << 'EOF'

[profile flyt-staging]
sso_start_url = https://acas.awsapps.com/start
sso_region = eu-west-1
sso_account_id = 364123201955
sso_role_name = jetc-developer
region = eu-west-1

[profile flyt-production]
sso_start_url = https://acas.awsapps.com/start
sso_region = eu-west-1
sso_account_id = 470025225193
sso_role_name = jetc-developer
region = eu-west-1
EOF
```

### Key Profiles

| Profile | Account ID | Environment | Use for |
|---------|-----------|-------------|---------|
| `flyt-staging` | 364123201955 | staging | Investigating staging errors, testing IAM changes |
| `flyt-production` | 470025225193 | production | Investigating production errors, IAM roles, S3 buckets |

### Bucket Naming Convention

JetConnect S3 buckets follow this pattern:
```
{environment}-{service-name}-{bucket-name}
```

Examples:
- `production-order-amendments-plu-mappings` — owned by order-amendments, bucket name "plu-mappings"
- `production-justeat-ordering-bridge-default` — owned by justeat-ordering-bridge, bucket name "default"
- `production-plu-emitter-plu-mappings` — owned by plu-emitter, bucket name "plu-mappings"

To decode a bucket ARN from a DataDog error: split on `-` to identify `{environment}-{service}-{bucket}`.

### Cross-Service S3 Access

When a service reads from a bucket it does not own, the IAM policy for that service must explicitly grant access to the foreign bucket. If a dev-tool upgrade regenerates IAM policies, cross-service grants may be silently dropped.

Signs of a dropped cross-service grant:
- `AccessDenied: s3:ListBucket` or `s3:GetObject` errors in DataDog
- The bucket name in the ARN belongs to a different service
- Errors started after a `chore: upgrade dev-tool` commit

Fix: restore the cross-service bucket permissions in `service.json` (if dev-tool supports this) or re-apply the IAM policy manually.

### JetConnect Gotchas

| Symptom | Cause | Fix |
|---------|-------|-----|
| Commands work but return wrong region | Wrong default region | Always pass `--region eu-west-1` for JetConnect resources |
| Cross-service S3 `AccessDenied` after upgrade | dev-tool regenerated IAM policies, dropping grants | Restore cross-service bucket permissions in `service.json` |
