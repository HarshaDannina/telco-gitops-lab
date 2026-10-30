#!/usr/bin/env bash
# Checks tools and WSL kernel modules the lab needs.
set -uo pipefail
ok=1

for tool in docker kind kubectl helm git; do
  if command -v "$tool" >/dev/null; then
    echo "ok    $tool"
  else
    echo "MISS  $tool"; ok=0
  fi
done

docker info >/dev/null 2>&1 && echo "ok    docker daemon running" || { echo "MISS  docker daemon not reachable"; ok=0; }

# NGAP (gNB <-> AMF) runs over SCTP and the UPF needs a TUN device.
# On WSL2 both are loadable modules, not built in.
for mod in sctp tun; do
  if lsmod | grep -q "^$mod " || [ -e "/sys/module/$mod" ]; then
    echo "ok    kernel module $mod"
  elif sudo modprobe "$mod" 2>/dev/null; then
    echo "ok    kernel module $mod (loaded now)"
  else
    echo "MISS  kernel module $mod (run: wsl --update from Windows, then retry)"; ok=0
  fi
done

mem_gb=$(awk '/MemTotal/ {printf "%d", $2/1024/1024}' /proc/meminfo)
[ "$mem_gb" -ge 7 ] && echo "ok    ${mem_gb} GB RAM" || echo "WARN  only ${mem_gb} GB RAM; set memory=8GB in %UserProfile%\\.wslconfig"

[ "$ok" = 1 ] && echo "Preflight passed." || { echo "Preflight failed."; exit 1; }
