#!/bin/bash
set -euo pipefail

systemctl daemon-reload

apt-get -qq update
apt-get -qq install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF > /etc/apt/sources.list.d/docker-and-kubernetes.list
deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable
deb http://packages.cloud.google.com/apt/ kubernetes-xenial main
EOF

apt-get -qq update
apt-get -qq install -y docker-ce
apt-get -qq install -y kubelet=${kubernetes_version}-* kubeadm=${kubernetes_version}-* kubectl=${kubernetes_version}-*
sysctl -p
