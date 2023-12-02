# DevOps GitOps Stack

Flux 2.7+ GitOps platform with layered infrastructure and multi-tenancy.

## Stack

| Component | Version | Layer |
|-----------|---------|-------|
| Cilium | 1.16+ | core |
| cert-manager | 1.16+ | network |
| Gateway API | v1 | network |
| Capsule | 0.7+ | security |
| Kyverno | 3.3+ | security |

## Quick Start

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
  --data-dir /data/k3s \
  --flannel-backend=none \
  --disable-network-policy \
  --disable-kube-proxy \
  --disable=traefik \
  --disable=servicelb \
  --tls-san=192.168.1.XX" \
  sh -
```

```bash
cd .dev && task
```

## Structure

```
cluster/kubernetes/
├── infrastructure.yaml        # Layer orchestration
├── kustomization.yaml         # Flux bootstrap entry
└── tenants/                   # Tenant definitions
    ├── config.yaml            # Shared ConfigMap
    ├── xonery.yaml            # Tenant: xonery
    └── kustomization.yaml

infrastructure/
├── cilium/                    # Layer 0: Core
├── network/                   # Layer 1: Network
│   ├── cert-manager/
│   └── gateway/
└── security/                  # Layer 2: Security
    ├── capsule/
    └── kyverno/

tenants/base/                  # Tenant template
├── namespace.yaml
├── rbac.yaml
├── flux.yaml
└── network.yaml
```

## Dependency Graph

```
core (cilium)
    ↓
network (cert-manager, gateway)
    ↓
security (capsule, kyverno)
    ↓
tenants (orchestrator)
    ↓
tenant-xonery, tenant-xxx, ...
```

## Add Tenant

1. Create `cluster/kubernetes/tenants/{name}.yaml`:

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: tenant-myapp
  namespace: flux-system
spec:
  sourceRef:
    kind: GitRepository
    name: flux-system
  path: ./tenants/base
  interval: 30m
  retryInterval: 2m
  timeout: 5m
  prune: true
  wait: true
  postBuild:
    substitute:
      TENANT: myapp
      DOMAIN: myapp.local
      REPO: https://github.com/org/myapp
    substituteFrom:
      - kind: ConfigMap
        name: tenant-defaults
  commonMetadata:
    labels:
      app.kubernetes.io/part-of: myapp
      capsule.clastix.io/tenant: developers
```

2. Add to `cluster/kubernetes/tenants/kustomization.yaml`:

```yaml
resources:
  - config.yaml
  - xonery.yaml
  - myapp.yaml  # Add here
```

## Tenant Variables

| Variable | Source | Description |
|----------|--------|-------------|
| `TENANT` | tenant yaml | Namespace name |
| `DOMAIN` | tenant yaml | Tenant domain |
| `REPO` | tenant yaml | Git repository |
| `BRANCH` | ConfigMap | Git branch (default: main) |
| `ISSUER` | ConfigMap | ClusterIssuer (default: selfsigned) |
| `GATEWAY_NS` | ConfigMap | Gateway namespace |
| `GATEWAY_NAME` | ConfigMap | Gateway name |
