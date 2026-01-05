# DevOps GitOps Infrastructure

Minimal instructions to bootstrap this repository: install Cilium for networking, deploy Flux, and enable SOPS-encrypted secrets.

## Requirements

- macOS or Linux workstation with `kubectl`, `flux`, `sops`, `age`, and (`helm` or `cilium` CLI) installed. On macOS: `brew install kubectl flux sops age helm`.
- Kubernetes 1.28+ cluster (k3s recommended) with cluster-admin access.
- GitHub repository with personal access token.

Repository layout (trimmed):

```
clusters/                 # Flux entrypoint
infrastructure/
  controllers/01-cilium/  # Flux-managed Cilium HelmRelease
  configs/01-secrets/     # SOPS-encrypted platform secrets
tenants/                  # Tenant examples
.sops.yaml                # Encryption rules
```

## Quick Start

### 1. Provision k3s (no CNI)

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
  --flannel-backend=none \
  --disable-network-policy \
  --disable-kube-proxy \
  --disable=traefik \
  --disable=servicelb" \
  sh -

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```

### 2. Install a bootstrap Cilium

A working CNI must exist before Flux controllers can schedule. Install Cilium once out-of-band, matching the namespace and chart version managed in this repo:

```bash
helm repo add cilium https://helm.cilium.io
helm upgrade --install cilium cilium/cilium \
  --namespace cilium \
  --create-namespace \
  --version 1.17.2
```

When Flux comes online it will reconcile the HelmRelease in [infrastructure/controllers/01-cilium/release.yaml](infrastructure/controllers/01-cilium/release.yaml) using the same release name, so no manual cleanup is required.

### 3. Bootstrap Flux

```bash
export GITHUB_TOKEN=<github-token>
export GITHUB_USER=<github-username>
export GITHUB_REPO=devops

flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=$GITHUB_REPO \
  --branch=main \
  --path=./clusters \
  --personal \
  --private=false
```

Verify controllers:

```bash
flux get kustomizations
flux get helmreleases -A
```

### 4. Configure SOPS

Generate an age key and record the public key in `.sops.yaml` (replace the placeholder value):

```bash
age-keygen -o age.agekey
```

Create the Flux decryption secret and remove the local private key after backup:

```bash
kubectl create secret generic sops-age \
  --namespace=flux-system \
  --from-file=age.agekey=age.agekey

rm age.agekey
```

Flux will decrypt every secret listed in [infrastructure/configs/01-secrets/kustomization.yaml](infrastructure/configs/01-secrets/kustomization.yaml) and any tenant secret under `tenants/*/secrets/`.

## Day 2 Basics

- Reconcile everything: `flux reconcile kustomization flux-system --with-source`
- Check Helm status: `flux get helmreleases -A`
- Add new encrypted secret: create YAML, run `sops --encrypt --in-place <file>`, commit, and Flux applies automatically.

## Recovering a Cluster

If the cluster is rebuilt, repeat steps 1–3, restore the age private key, recreate the `sops-age` secret, and Flux will repave the platform from Git.
