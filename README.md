# DevOps GitOps Infrastructure

Minimal instructions to bootstrap the Raspberry Pi cluster with Cilium, FluxCD, and SOPS.

## 1. Provision K3s (Hardcore Mode)

Install K3s without CNI, kube-proxy, or Traefik to let Cilium handle everything.

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
  --data-dir /data/k3s \
  --disable-kube-proxy \
  --flannel-backend=none \
  --disable-network-policy \
  --disable traefik,servicelb,local-storage \
  --tls-san citroen \
  --tls-san citroen.dev \
  --cluster-cidr 10.42.0.0/16 \
  --write-kubeconfig-mode 644" \
  sh -

# Setup Kubeconfig
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config

export KUBECONFIG=~/.kube/config
```

## 2. Bootstrap Cilium

A working CNI must exist before Flux can schedule pods. Install Cilium manually once; Flux will take over management later.

<!-- ```bash
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}

kubectl create namespace cilium-system

# Install with flags that match our GitOps config to prevent network flaps later
cilium install \
  --version 1.16.5 \
  --namespace cilium-system \
  --set routingMode=tunnel \
  --set tunnelProtocol=vxlan \
  --set kubeProxyReplacement=true \
  --set ipam.mode=kubernetes \
  --set operator.replicas=1

cilium status -n cilium-system --wait

kubectl run debug --image=curlimages/curl --rm -it --restart=Never -- curl -Iv https://github.com
``` -->

```bash
helm repo add cilium https://helm.cilium.io
helm repo update

helm install cilium cilium/cilium --version 1.18.5 \
  --namespace cilium-system --create-namespace \
  --set k8sServiceHost=127.0.0.1 \
  --set k8sServicePort=6443 \
  --set kubeProxyReplacement=true \
  --set operator.replicas=1

cilium status -n cilium-system --wait

kubectl run debug --image=curlimages/curl --rm -it --restart=Never -- curl -Iv https://github.com

# cilium uninstall -n cilium-system
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

# flux uninstall
```

## 5. Monitor

```bash
flux get kustomizations --watch
flux get helmreleases -A
kubectl get pods -A
```