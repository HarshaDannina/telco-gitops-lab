#!/usr/bin/env bash
# Checks that the core is up, the gNB is attached and a UE can reach the internet.
set -uo pipefail
NS=open5gs

echo "== Argo CD applications"
kubectl -n argocd get applications

echo "== Pods in $NS"
kubectl -n $NS get pods

echo "== gNB attached to AMF?"
kubectl -n $NS logs deploy/open5gs-amf --tail=200 | grep -E "gNB|Number of gNBs" | tail -3

echo "== UE PDU sessions"
kubectl -n $NS logs deploy/ueransim-gnb-ues --tail=200 | grep -E "PDU Session establishment is successful|uesimtun" | tail -4

echo "== Ping through the user plane (uesimtun0)"
kubectl -n $NS exec deploy/ueransim-gnb-ues -- ping -c 3 -I uesimtun0 8.8.8.8
