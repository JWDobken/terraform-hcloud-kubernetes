#!/bin/bash
set -euo pipefail

[ -e /tmp/access_tokens.conf ] && rm /tmp/access_tokens.conf

until $(nc -z ${control_plane_private_ip} 6443); do
  echo "Waiting for API server to respond"
  sleep 5
done

token=$(cat /tmp/kubeadm_token)

# join the worker nodes
[ -f /etc/containerd/config.toml ] && rm /etc/containerd/config.toml
systemctl restart containerd
kubeadm join --token=$${token} ${control_plane_private_ip}:6443 \
  --discovery-token-unsafe-skip-ca-verification \
  --ignore-preflight-errors=Swap
