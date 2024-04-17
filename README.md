# Ansible

```
python3 -m pip install --user ansible

python3 -m ansible playbook ./ansible/playbook.yaml -i ./ansible/inventory/

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```

# K9S

```
k9s --kubeconfig /etc/rancher/k3s/k3s.yaml

sudo iptables -F

sudo iptables -I INPUT -p tcp -m tcp --dport 6443 -j ACCEPT

sudo iptables -t nat -A PREROUTING -d 10.0.0.239 -p tcp --dport 80 -j DNAT --to-destination 10.0.0.240:80
sudo iptables -t nat -A PREROUTING -d 10.0.0.239 -p tcp --dport 443 -j DNAT --to-destination 10.0.0.240:443

sudo iptables-save
```

# Flux

```
export FLUX_VERSION=2.2.3
curl -s https://fluxcd.io/install.sh | sudo bash

flux bootstrap github --owner=stupside --repository=devops --branch=main --path=/kubernetes/clusters/dev
```

## Debug

```
flux get kustomizations --watch

flux get all --all-namespaces

flux logs --follow --level=error --all-namespaces

kubectl -n flux-system get receiver/flux-system
```
