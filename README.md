# Ansible

```
python3 -m pip install --user ansible

ansible-playbook ansible/playbook/site.yaml -i ansible/inventory.yaml
```

# K9S

```
k9s
```

# Flux

```
export FLUX_VERSION=2.2.3
curl -s https://fluxcd.io/install.sh | sudo bash

flux bootstrap github --owner=stupside --repository=devops --branch=main --path=/kubernetes/clusters/dev
```

# Firewall

```
sudo iptables -F

sudo iptables -I INPUT -p tcp -m tcp --dport 6443 -j ACCEPT

sudo iptables -t nat -A PREROUTING -d 10.0.0.239 -p tcp --dport 80 -j DNAT --to-destination 10.0.0.240:80
sudo iptables -t nat -A PREROUTING -d 10.0.0.239 -p tcp --dport 443 -j DNAT --to-destination 10.0.0.240:443

sudo iptables-save
```

## Debug

```
flux get kustomizations --watch

flux get all --all-namespaces

flux logs --follow --level=error --all-namespaces

kubectl -n flux-system get receiver/flux-system
```
