#!/usr/bin/env bash
set -euo pipefail

if ! command -v git >/dev/null 2>&1; then
  echo "git is required" >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "gh (GitHub CLI) is required" >&2
  exit 1
fi

GIT_DIR="${HARNESS_GIT_DIR:-/workspace}"
GITHUB_REMOTE="${HARNESS_GITHUB_REMOTE:-fork}"
BASE_BRANCH="${HARNESS_BASE_BRANCH:-master}"
REPO_SLUG="${HARNESS_GITHUB_REPO:-}"

ensure_gh_auth_context() {
  if gh auth status -h github.com >/dev/null 2>&1; then
    return 0
  fi

  if [[ -n "${GH_CONFIG_DIR:-}" ]]; then
    return 1
  fi

  local candidates=(
    "/paperclip/.config/gh"
    "$HOME/.config/gh"
  )

  local dir
  for dir in "${candidates[@]}"; do
    if [[ -f "$dir/hosts.yml" ]]; then
      export GH_CONFIG_DIR="$dir"
      if gh auth status -h github.com >/dev/null 2>&1; then
        echo "Using GH_CONFIG_DIR=$GH_CONFIG_DIR" >&2
        return 0
      fi
    fi
  done

  return 1
}

if ! git -C "$GIT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not a git repository: $GIT_DIR" >&2
  exit 1
fi

if ! git -C "$GIT_DIR" remote get-url "$GITHUB_REMOTE" >/dev/null 2>&1; then
  echo "Missing git remote '$GITHUB_REMOTE' in $GIT_DIR" >&2
  echo "Set HARNESS_GITHUB_REMOTE to an existing remote, or add one first." >&2
  exit 1
fi

if [[ -z "$REPO_SLUG" ]]; then
  remote_url="$(git -C "$GIT_DIR" remote get-url "$GITHUB_REMOTE")"
  if [[ "$remote_url" =~ github\.com[:/]+([^/]+)/([^/.]+)(\.git)?$ ]]; then
    REPO_SLUG="${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
  else
    echo "Could not derive GitHub repo slug from remote URL: $remote_url" >&2
    echo "Set HARNESS_GITHUB_REPO (example: owner/repo)." >&2
    exit 1
  fi
fi

if ! ensure_gh_auth_context; then
  echo "GitHub CLI is not authenticated inside this environment." >&2
  echo "Tip: in adapter runtimes with temporary XDG config, set GH_CONFIG_DIR=/paperclip/.config/gh" >&2
  echo "Run: gh auth login" >&2
  exit 1
fi

gh repo view "$REPO_SLUG" --json name >/dev/null

has_issues="$(gh api "repos/$REPO_SLUG" --jq '.has_issues')"
if [[ "$has_issues" != "true" ]]; then
  echo "Warning: GitHub Issues are disabled on $REPO_SLUG." >&2
fi

if ! git -C "$GIT_DIR" ls-remote "$GITHUB_REMOTE" >/dev/null 2>&1; then
  echo "Cannot access remote '$GITHUB_REMOTE' from $GIT_DIR." >&2
  echo "Check git credentials/permissions for $REPO_SLUG." >&2
  exit 1
fi

echo "GitHub integration ready for harness runs."
echo "repo: $REPO_SLUG"
echo "remote: $GITHUB_REMOTE"
echo "base branch: $BASE_BRANCH"
echo
echo "Recommended Builder flow in shared workspace mode:"
echo "1) create/switch issue branch"
echo "2) commit changes"
echo "3) push: git -C $GIT_DIR push -u $GITHUB_REMOTE <branch>"
echo "4) PR: gh -R $REPO_SLUG pr create --base $BASE_BRANCH --head <branch> ..."
echo "5) post PR URL to Paperclip issue comment"
echo "6) switch back: git -C $GIT_DIR switch $BASE_BRANCH"
