#!/usr/bin/env bash
# Deletes the whole lab. Everything comes back with make bootstrap, because it lives in Git.
set -euo pipefail
kind delete cluster --name telco-lab
