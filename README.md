# Sync Repo

```bash
git checkout .
git pull --rebase
```

# Docker

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER && newgrp docker
```

# K3S

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --disable traefik" sh -

export KUBECONFIG=~/.kube/config
sudo cp /etc/rancher/k3s/k3s.yaml $KUBECONFIG
```

# Overlays

```bash
kubectl apply -k ./kubernetes/<something>/overlay
```
