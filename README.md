# DevOps GitOps Infrastructure

Minimal instructions to bootstrap the Raspberry Pi cluster with Cilium, FluxCD, and SOPS.

## 1. Provision K3s (Hardcore Mode)

Install K3s without CNI, kube-proxy, or Traefik to let Cilium handle everything.

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
  --data-dir /data/k3s \
  --flannel-backend=none \
  --disable-network-policy \
  --disable-kube-proxy \
  --disable=traefik \
  --disable=servicelb \
  --tls-san=citroen \
  --tls-san=citroen.local" \
  sh -

# Setup Kubeconfig
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
export KUBECONFIG=~/.kube/config
```

## 2. Bootstrap Cilium

A working CNI must exist before Flux can schedule pods. Install Cilium manually once; Flux will take over management later.

```bash
helm repo add cilium https://helm.cilium.io/
helm repo update

helm upgrade --install cilium cilium/cilium \
  --namespace cilium \
  --create-namespace \
  --version 1.17.2 \
  --set k8sServiceHost=127.0.0.1 \
  --set k8sServicePort=6443 \
  --set kubeProxyReplacement=true \
  --set operator.replicas=1 \
  --set ipam.mode=kubernetes \
  --set bpf.masquerade=true \
  --set gatewayAPI.enabled=true
```

## 3. Setup Secrets (SOPS + Age)

Restore your private key and create the Flux decryption secret.

```bash
# Create namespace
kubectl create namespace flux-system

# Create the secret from your local age.agekey
kubectl create secret generic sops-age \
  --namespace=flux-system \
  --from-file=age.agekey=age.agekey
```

## 4. Bootstrap FluxCD

Initialize the GitOps engine.

```bash
export GITHUB_TOKEN=<your-token>
export GITHUB_USER=stupside
export GITHUB_REPO=devops

flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=$GITHUB_REPO \
  --branch=main \
  --path=./clusters \
  --personal \
  --private=false
```

## 5. Monitor

```bash
flux get kustomizations --watch
flux get helmreleases -A
kubectl get pods -A
```

