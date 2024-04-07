# Ansible

```
python3 -m pip install --user ansible

python3 -m ansible playbook ./ansible/playbook.yaml -i ./ansible/inventory/

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```

# Flux

```
export FLUX_VERSION=2.2.3
curl -s https://fluxcd.io/install.sh | sudo bash

flux bootstrap github --owner=stupside --repository=devops --branch=main --path=/kubernetes/clusters/dev --interval=30s

flux get kustomizations --watch
flux get all --all-namespaces
flux logs --follow --level=error --all-namespaces
```

# K9S

```
k9s --kubeconfig /etc/rancher/k3s/k3s.yaml
```
