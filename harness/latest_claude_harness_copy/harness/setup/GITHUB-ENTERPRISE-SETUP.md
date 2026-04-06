# GitHub Enterprise CLI Setup

GHE instance: `github.je-labs.com`
Preferred tool: `gh` (the official GitHub CLI). The `ghi` tool is a legacy wrapper — do not use it for new work.

---

## 1. Install gh CLI

```sh
brew install gh
```

Verify:

```sh
gh --version
```

---

## 2. Authenticate with the GHE hostname

The `--hostname` flag is required. Without it, `gh` defaults to `github.com` and all operations will fail or target the wrong instance.

```sh
gh auth login --hostname github.je-labs.com
```

When prompted:

- **What account do you want to log into?** — GitHub Enterprise Server
- **Hostname** — `github.je-labs.com`
- **How would you like to authenticate?** — Paste an authentication token

You will need a Personal Access Token (PAT). See section 3.

---

## 3. Create a Personal Access Token (PAT)

1. Go to `https://github.je-labs.com/settings/tokens`
2. Click **Generate new token (classic)**
3. Set a descriptive note (e.g. `gh-cli-local`)
4. Select the following scopes (minimum required):

   | Scope | Required for |
   |-------|-------------|
   | `repo` | Reading and writing repositories, issues, PRs |
   | `read:org` | Listing org repos, checking team membership |
   | `workflow` | Triggering and reading GitHub Actions workflows |

5. Click **Generate token** and copy it immediately — it will not be shown again.

---

## 4. Authorize the token for SSO (if required)

If the organization enforces SAML SSO, the token must be explicitly authorized after creation:

1. On the token list page (`https://github.je-labs.com/settings/tokens`), find your new token.
2. Click **Configure SSO** next to the token.
3. Click **Authorize** next to the organization (e.g. `grocery-and-retail-growth`).

Without this step, API calls will return `403` or "Resource not accessible by integration" errors even though the token itself is valid.

---

## 5. 2FA

If your account has 2FA enabled (required for most orgs), the PAT flow above handles authentication without requiring a second factor at the CLI. However, you must complete 2FA when logging into the web UI to create or manage tokens.

Supported 2FA methods: authenticator app (TOTP), SMS (if enabled by org admin).

---

## 6. Test the connection

```sh
gh auth status --hostname github.je-labs.com
```

Expected output:

```
github.je-labs.com
  ✓ Logged in to github.je-labs.com as <your-username> (<token-source>)
  ✓ Token: <scopes>
```

Also verify repo access:

```sh
gh repo view grocery-and-retail-growth/testharness --hostname github.je-labs.com
```

---

## 7. Set the default hostname (optional but recommended)

To avoid passing `--hostname` on every command, set it as the default:

```sh
gh config set -h github.je-labs.com git_protocol ssh
```

Or export it in your shell profile:

```sh
export GH_HOST=github.je-labs.com
```

---

## 8. Common errors and fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `Could not resolve to a Repository` | SSO not authorized for token | Authorize token for SSO (section 4) |
| `Resource not accessible by integration` | Missing scope or SSO not authorized | Add required scope or authorize SSO |
| `Must specify an Org` or `403` on org endpoints | Missing `read:org` scope | Regenerate token with `read:org` |
| `gh: command not found` | gh not installed | `brew install gh` |
| Auth prompt loops or fails | Defaulting to github.com | Always use `--hostname github.je-labs.com` |

---

## 9. Note on ghi

The `ghi` tool (`gem install ghi`) is a legacy CLI wrapper for GitHub Issues. It is not maintained, does not support GitHub Enterprise Server properly, and does not understand PATs or SSO. Do not use `ghi` for any operations in this project — use `gh issue` and `gh pr` instead.
