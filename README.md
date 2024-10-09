# Devops

## Setup server

`ansible-playbook playbooks/site.yml`

`export KUBECONFIG=/etc/rancher/k3s/k3s.yaml`

`flux bootstrap github --personal --owner=stupside --repository=devops --path=/kubernetes/clusters/dev`

`flux reconcile kustomization flux-system --with-source`

`flux get kustomizations --watch`
`kubectl get kustomizations -n flux-system`

`flux get kustomization xonery-release --namespace xonery-ns`

`kubectl get ingress -A`

iptables -A INPUT -i eth0 -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -i eth0 -p tcp -m tcp --dport 443 -j ACCEPT
