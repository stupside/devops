# Get default admin password if enabled

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

# Update the password for an account

```bash
kubectl -n argocd account update-password --account argo-account --current-password <old> --new-password <new>
```
