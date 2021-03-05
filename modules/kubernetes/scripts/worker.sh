#!/bin/bash
set -euo pipefail

LOCAL_IP=$(ifconfig ens10 | grep 'inet ' | cut -d: -f2 | awk '{print $2}')
printf "[Service]
Environment=\"KUBELET_EXTRA_ARGS=--node-ip=$LOCAL_IP\"" \
| tee /etc/systemd/system/kubelet.service.d/30-internal-ip.conf

[ -e /tmp/access_tokens.conf ] && rm /tmp/access_tokens.conf

until $(nc -z ${master_private_ip} 6443); do
  echo "Waiting for API server to respond"
  sleep 5
done

token=$(cat /tmp/kubeadm_token)

kubeadm join --token=$${token} ${master_private_ip}:6443 \
  --discovery-token-unsafe-skip-ca-verification \
  --ignore-preflight-errors=Swap
