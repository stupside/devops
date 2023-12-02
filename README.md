# devops

## flux
```
flux bootstrap github --personal --owner=stupside --repository=devops --path=/cluster/kubernetes
```

## grafana
```
kubectl get secret --namespace monitoring monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 --decode; echo;
```

## LB
```
kubectl get svc -n ingress-nginx | grep LoadBalancer | awk '{print $4}'
```

```
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -i eth0 -j DNAT --to-destination=12.10.0.10:80
sudo iptables -t nat -A PREROUTING -p tcp --dport 443 -i eth0 -j DNAT --to-destination=12.10.0.10:443
```