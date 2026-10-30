#!/usr/bin/env bash
# Creates the kind cluster, installs Argo CD, then hands everything else to Git.
set -euo pipefail
ARGOCD_VERSION="${ARGOCD_VERSION:-v3.5.6}"

if grep -rq 'REPO_URL' bootstrap apps; then
  echo "Run scripts/set-repo-url.sh first."; exit 1
fi

kind get clusters | grep -qx telco-lab || kind create cluster --config cluster/kind-config.yaml

kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd --server-side --force-conflicts \
  -f "https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml"
kubectl -n argocd rollout status deploy/argocd-server --timeout=300s
kubectl -n argocd rollout status deploy/argocd-repo-server --timeout=300s

kubectl apply -f bootstrap/gradiant-helm-oci.yaml
kubectl apply -f bootstrap/root-app.yaml

echo
echo "Argo CD admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo
echo "Open the UI with: make ui   (https://localhost:8080, user admin)"
