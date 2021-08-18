Hetzner Cloud Kubernetes provider 🏖️
==================

Unofficial Terraform module to provide Kubernetes for the Hetzner Cloud.

[![JWDobken](https://circleci.com/gh/JWDobken/terraform-hcloud-kubernetes.svg?style=shield)](https://app.circleci.com/pipelines/github/JWDobken/terraform-hcloud-kubernetes?branch=main)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/JWDobken/terraform-hcloud-kubernetes?label=release)](https://github.com/JWDobken/terraform-hcloud-kubernetes/releases)
![license](https://img.shields.io/github/license/JWDobken/terraform-hcloud-kubernetes.svg)

Create a Kubernetes cluster on the [Hetzner cloud](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs), with the following features:

- implements Hetzner's [private network](https://community.hetzner.com/tutorials/hcloud-networks-basic) for network security
- configures [UFW](https://help.ubuntu.com/community/UFW) for managing complex iptables rules
- deploys the [Flannel](https://github.com/coreos/flannel) CNI plugin
- deploys the [Controller Manager](https://github.com/hetznercloud/hcloud-cloud-controller-manager) with networks support, to integrate with the Hetzner Cloud API
- deploys the [Container Storage Interface](https://github.com/hetznercloud/csi-driver) for dynamic provisioning of volumes

# Getting Started

The Hetzner Cloud provider needs to be configured with *a token generated from the dashboard*, following to the [documentation](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs). Provide a [Hetzner Cloud SSH key resource](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/ssh_key) to access the cluster machines:

```hcl
resource "hcloud_ssh_key" "demo_cluster" {
  name       = "demo-cluster"
  public_key = file("~/.ssh/hcloud.pub")
}
```

Create a Kubernetes cluster:

```hcl
module "hcloud_kubernetes_cluster" {
  source          = "JWDobken/kubernetes/hcloud"
  cluster_name    = "demo-cluster"
  hcloud_token    = var.hcloud_token
  hcloud_ssh_keys = [hcloud_ssh_key.demo_cluster.id]
  master_type     = "cx11" # optional
  worker_type     = "cx21" # optional
  worker_count    = 3
}

output "kubeconfig" {
  value = module.hcloud_kubernetes_cluster.kubeconfig
}

```

When the cluster is deployed, the `kubeconfig` to reach the cluster is available from the output. There are many ways to continue, but you can store it to file:

```cmd
terraform output -raw kubeconfig > demo-cluster.conf
```

and check the access by viewing the created cluster nodes:

```cmd
$ kubectl get nodes --kubeconfig=demo-cluster.conf
NAME       STATUS   ROLES    AGE   VERSION
master-1   Ready    master   95s   v1.18.9
worker-1   Ready    <none>   72s   v1.18.9
worker-2   Ready    <none>   73s   v1.18.9
worker-3   Ready    <none>   73s   v1.18.9
```

## Load Balancer

The [Controller Manager](https://github.com/hetznercloud/hcloud-cloud-controller-manager/blob/master/docs/load_balancers.md) deploys a load balancer for any `Service` of type `LoadBalancer`, that can be configured with `service.annotations`. It is also possible to create the load balancer within the network using the [Terraform provider](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer):

```hcl
resource "hcloud_load_balancer" "load_balancer" {
  name               = "demo-cluster-lb"
  load_balancer_type = "lb11"
  location           = "nbg1"
}

resource "hcloud_load_balancer_network" "cluster_network" {
  load_balancer_id = hcloud_load_balancer.load_balancer.id
  network_id       = module.hcloud_kubernetes_cluster.network_id
}
```

...and pass the name to the `service.annotations`. For example, deploy the ingress-controller, such as [Bitnami's Nginx Ingress Controller](https://github.com/bitnami/charts/tree/master/bitnami/nginx-ingress-controller), with the name of the load balancer as an annotation:

```cmd
helm repo add bitnami https://charts.bitnami.com/bitnami
helm upgrade --install nginx-ingress \
    --version 5.6.13 \
    --set service.annotations."load-balancer\.hetzner\.cloud/name"="demo-cluster-lb" \
    bitnami/nginx-ingress-controller
```

## Chaining other terraform modules

TLS certificate credentials form the output can be used to chain other Terraform modules, such as the [Helm provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs) or the [Kubernetes provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs):

```hcl
provider "helm" {
  kubernetes {
    host     = module.hcloud_kubernetes_cluster.endpoint

    cluster_ca_certificate = base64decode(module.hcloud_kubernetes_cluster.certificate_authority_data)
    client_certificate     = base64decode(module.hcloud_kubernetes_cluster.client_certificate_data)
    client_key             = base64decode(module.hcloud_kubernetes_cluster.client_key_data)
  }
}

provider "kubernetes" {
  host = module.hcloud_kubernetes_cluster.endpoint

  client_certificate     = base64decode(module.hcloud_kubernetes_cluster.client_certificate_data)
  client_key             = base64decode(module.hcloud_kubernetes_cluster.client_key_data)
  cluster_ca_certificate = base64decode(module.hcloud_kubernetes_cluster.client_certificate_data)
}
```

## Considered features:

- When a node is destroyed, I still need to run `kubectl drain <nodename>` and `kubectl delete node <nodename>`. Compare actual list with `kubectl get nodes --output 'jsonpath={.items[*].metadata.name}'`.
- [High availability for the control plane](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/).
- Node-pool architecture, with option to label and taint.
- Initialize multiple master nodes.

## Acknowledgements 

This module came about when I was looking for an affordable Kubernetes cluster. There is an [article from Christian Beneke](https://community.hetzner.com/tutorials/install-kubernetes-cluster) and there are a couple of Terraform projects on which the current is heavily based:

- Patrick Stadler's [hobby-kube provisioning](https://github.com/hobby-kube/provisioning)
- Niclas Mietz's [terraform-k8s-hcloud](https://github.com/solidnerd/terraform-k8s-hcloud)

Feel free to contribute or reach out to me.
