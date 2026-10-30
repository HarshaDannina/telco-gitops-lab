#!/usr/bin/env bash
# Writes your GitHub repo URL into the Argo CD manifests (replaces REPO_URL).
set -euo pipefail
url="${1:-$(git remote get-url origin 2>/dev/null || true)}"
[ -n "$url" ] || { echo "usage: $0 https://github.com/<you>/telco-gitops-lab.git"; exit 1; }
# Argo CD needs https for a public repo without credentials.
url=$(echo "$url" | sed -E 's#^git@github.com:#https://github.com/#')
grep -rl 'REPO_URL' bootstrap apps | xargs sed -i "s#REPO_URL#$url#g"
echo "Repo URL set to $url. Commit and push before running make bootstrap."
