#!/bin/bash
set -euo pipefail

LOCAL_IP=$(ifconfig ens10 | grep 'inet ' | cut -d: -f2 | awk '{print $2}')
printf "[Service]
Environment=\"KUBELET_EXTRA_ARGS=--node-ip=$LOCAL_IP\"" \
| tee /etc/systemd/system/kubelet.service.d/30-internal-ip.conf

# initialize the cluster
kubeadm config images pull
kubeadm init \
  --pod-network-cidr=10.244.0.0/16 \
  --kubernetes-version=v${kubernetes_version} \
  --ignore-preflight-errors=Swap,NumCPU \
  --apiserver-cert-extra-sans=${master_ip}

# Configure kubectl to connect to the kube-apiserver
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
kubectl --kubeconfig $HOME/.kube/config config \
  rename-context "kubernetes-admin@kubernetes" "${cluster_name}"

until nc -z localhost 6443; do
  echo "Waiting for API server to respond"
  sleep 5
done

# patch tollerations for coredns
kubectl -n kube-system patch deployment coredns --type json -p '[{"op":"add","path":"/spec/template/spec/tolerations/-","value":{"key":"node.cloudprovider.kubernetes.io/uninitialized","value":"true","effect":"NoSchedule"}}]'

# create the secrets with Hetzner Cloud API tokens
kubectl apply -f /tmp/access_tokens.conf
[ -e /tmp/access_tokens.conf ] && rm /tmp/access_tokens.conf

# deploy the flannel CNI plugin
kubectl apply -f /tmp/kube-flannel.yaml

# Patch the flannel deployment to tolerate the uninitialized taint
kubectl -n kube-system patch ds kube-flannel-ds --type json -p '[{"op":"add","path":"/spec/template/spec/tolerations/-","value":{"key":"node.cloudprovider.kubernetes.io/uninitialized","value":"true","effect":"NoSchedule"}}]'

# deploy the Hetzner Cloud controller manager
kubectl apply -n kube-system -f /tmp/ccm-networks.yaml

# deploy the Hetzner Cloud Container Storage Interface
kubectl apply -f /tmp/hcloud-csi.yaml
