# DevOps GitOps Infrastructure

Production-ready Kubernetes platform using FluxCD v2.7.5 with layered infrastructure deployment, SOPS secret encryption, and Capsule-based multi-tenancy.

## Overview

This repository manages a complete Kubernetes infrastructure using GitOps principles:

- **GitOps Engine**: FluxCD v2.7.5
- **Cluster**: k3s with Cilium CNI
- **Secret Management**: Mozilla SOPS with age encryption
- **Multi-Tenancy**: Capsule v0.8.x
- **Policy Enforcement**: Kyverno v3.4.x
- **Certificate Management**: cert-manager v1.17.x
- **Networking**: Cilium v1.17.x + Gateway API v1.2.1

---

## Architecture

### Directory Structure

```
devops/
├── .sops.yaml                         # SOPS encryption configuration
├── clusters/                          # FluxCD bootstrap & orchestration
│   ├── flux-system/                   # FluxCD core components
│   │   ├── gotk-components.yaml       # Controllers & CRDs
│   │   ├── gotk-sync.yaml             # Bootstrap GitRepository
│   │   └── kustomization.yaml         # Flux patches
│   ├── infrastructure.yaml            # Infrastructure orchestration
│   ├── tenants.yaml                   # Tenant orchestration
│   └── kustomization.yaml             # Root entry point
│
├── infrastructure/                    # Platform infrastructure
│   ├── crds/                          # Custom Resource Definitions
│   │   └── gateway-api/               # Gateway API v1.2.1 CRDs
│   ├── controllers/                   # Platform controllers
│   │   ├── cilium/                    # CNI + Gateway controller
│   │   ├── cert-manager/              # Certificate automation
│   │   ├── capsule/                   # Multi-tenancy controller
│   │   └── kyverno/                   # Policy engine
│   └── configs/                       # Platform configuration
│       ├── gateway/                   # GatewayClass definitions
│       ├── certificates/              # ClusterIssuers
│       └── secrets/                   # Encrypted secrets (SOPS)
│
└── tenants/                           # Tenant workloads
    └── xonery/                        # Example tenant
        ├── tenant.yaml                # Capsule Tenant definition
        ├── gateway.yaml               # Gateway + TLS certificate
        ├── apps.yaml                  # External GitRepository
        └── secrets/                   # Tenant encrypted secrets
```

### Dependency Flow

```
Layer 0: CRDs (Gateway API)
    ↓ dependsOn
Layer 1: Controllers (Cilium, cert-manager, Capsule, Kyverno)
    ↓ dependsOn
Layer 2: Configs (Gateway, Certificates, Secrets)
    ↓ dependsOn
Layer 3: Tenants (Capsule Tenants + Apps)
```

**Key principles:**
- **Layered dependencies**: Each layer waits for the previous one
- **SOPS decryption**: Automatic secret decryption on Layers 2 & 3
- **External tenant repos**: Tenants manage apps in separate Git repositories

---

## Prerequisites

### Local Tools

```bash
# macOS
brew install kubectl flux age sops

# Linux
# kubectl: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
# flux: https://fluxcd.io/flux/installation/
# age: apt install age or from https://github.com/FiloSottile/age
# sops: https://github.com/getsops/sops/releases
```

### Infrastructure

- **Kubernetes cluster**: k3s 1.28+ (or any Kubernetes 1.28+)
- **Git repository**: GitHub/GitLab with SSH access
- **DNS**: Wildcard DNS or manual DNS entries for ingress

---

## Initial Setup

### Step 1: Install k3s

```bash
# Install k3s without Traefik and flannel (Cilium will be CNI)
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
  --flannel-backend=none \
  --disable-network-policy \
  --disable-kube-proxy \
  --disable=traefik \
  --disable=servicelb" \
  sh -

# Export kubeconfig
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```

### Step 2: Bootstrap FluxCD

```bash
# Set GitHub credentials
export GITHUB_TOKEN=<your-github-token>
export GITHUB_USER=<your-github-username>
export GITHUB_REPO=devops

# Bootstrap FluxCD
flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=$GITHUB_REPO \
  --branch=main \
  --path=./clusters \
  --personal \
  --private=false
```

**What this does:**
- Installs FluxCD controllers in `flux-system` namespace
- Creates `flux-system` GitRepository pointing to this repo
- Creates `flux-system` Kustomization syncing `./clusters` directory
- Commits `clusters/flux-system/` files to your repo

### Step 3: Setup SOPS Secret Encryption

#### 3.1 Generate Age Key

```bash
# Generate age encryption key pair
age-keygen -o age.agekey

# Output shows:
# Public key: age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
# File age.agekey written
```

**⚠️ IMPORTANT**: Save the private key (`age.agekey`) securely:
1. Store in password manager (1Password, Bitwarden, etc.)
2. Store encrypted backup in cloud storage
3. **NEVER commit** to Git (already in `.gitignore`)

#### 3.2 Create Kubernetes Secret

```bash
# Create secret with age private key
cat age.agekey | kubectl create secret generic sops-age \
  --namespace=flux-system \
  --from-file=age.agekey=/dev/stdin

# Verify secret exists
kubectl get secret sops-age -n flux-system

# Securely delete local file (after backing up!)
rm age.agekey
```

#### 3.3 Verify SOPS Configuration

The `.sops.yaml` file is already configured with encryption rules:

```yaml
creation_rules:
  # Infrastructure secrets
  - path_regex: infrastructure/configs/secrets/.*\.yaml
    encrypted_regex: ^(data|stringData)$
    age: age1xxxxxxxxx...  # Your public key

  # Tenant secrets
  - path_regex: tenants/.*/secrets/.*\.yaml
    encrypted_regex: ^(data|stringData)$
    age: age1xxxxxxxxx...  # Your public key
```

#### 3.4 Verify Decryption Works

```bash
# Force FluxCD to reconcile
flux reconcile kustomization flux-system --with-source
flux reconcile kustomization configs --with-source

# Check if test secret was decrypted and created
kubectl get secret test-secret -n default

# Verify decrypted value
kubectl get secret test-secret -n default -o jsonpath='{.data.test-key}' | base64 -d
# Should output: test-value
```

---

## SOPS Workflow

### Creating New Secrets

```bash
# 1. Create plain secret file
cat > infrastructure/configs/secrets/my-secret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
  namespace: default
type: Opaque
stringData:
  username: "admin"
  password: "super-secret"
EOF

# 2. Encrypt with SOPS (uses .sops.yaml rules)
sops --encrypt --in-place infrastructure/configs/secrets/my-secret.yaml

# 3. Add to kustomization
echo "  - my-secret.yaml" >> infrastructure/configs/secrets/kustomization.yaml

# 4. Commit encrypted secret
git add infrastructure/configs/secrets/my-secret.yaml
git add infrastructure/configs/secrets/kustomization.yaml
git commit -m "Add encrypted secret for my-app"
git push
```

### Editing Encrypted Secrets

```bash
# Edit secret (SOPS automatically decrypts in editor)
sops infrastructure/configs/secrets/my-secret.yaml

# Make changes, save, and exit
# SOPS automatically re-encrypts on save

# Commit changes
git add infrastructure/configs/secrets/my-secret.yaml
git commit -m "Update my-secret credentials"
git push
```

### Viewing Encrypted Secrets

```bash
# View decrypted content (doesn't modify file)
sops --decrypt infrastructure/configs/secrets/my-secret.yaml

# Extract specific value
sops --decrypt --extract '["stringData"]["password"]' \
  infrastructure/configs/secrets/my-secret.yaml
```

---

## Infrastructure Components

### Layer 0: CRDs

**Gateway API v1.2.1**
- Location: `infrastructure/crds/gateway-api/`
- Installed from: `https://github.com/kubernetes-sigs/gateway-api`
- Provides: GatewayClass, Gateway, HTTPRoute CRDs

### Layer 1: Controllers

#### Cilium (CNI + Gateway)
- **Version**: 1.17.x
- **Namespace**: `cilium`
- **Features**:
  - CNI networking (native routing mode)
  - Gateway API implementation
  - Hubble observability (UI enabled)
  - Network policies
- **Configuration**: `infrastructure/controllers/cilium/release.yaml`

#### cert-manager
- **Version**: 1.17.x
- **Namespace**: `cert-manager`
- **Features**: Automated certificate management
- **Issuers**: ClusterIssuer for self-signed certificates (see `infrastructure/configs/certificates/`)

#### Capsule (Multi-tenancy)
- **Version**: 0.8.x
- **Namespace**: `capsule`
- **Features**:
  - Namespace isolation per tenant
  - Resource quotas enforcement
  - Network policy injection
  - RBAC scoping
- **Tenant example**: `tenants/xonery/tenant.yaml`

#### Kyverno (Policy Engine)
- **Version**: 3.4.x
- **Namespace**: `kyverno`
- **Features**: Pod security policies, admission control, validation
- **Policies**: `infrastructure/controllers/kyverno/policies/` (to be added)

### Layer 2: Configs

- **GatewayClass**: Cilium-based gateway configuration
- **ClusterIssuers**: Self-signed certificate issuer
- **Secrets**: SOPS-encrypted secrets with automatic decryption

---

## Multi-Tenancy

### Tenant Architecture

Each tenant gets:
1. **Capsule Tenant resource** - Defines quotas, limits, network policies
2. **Dedicated Gateway** - Isolated ingress with TLS
3. **External Git repository** - Tenant manages their own apps
4. **Network isolation** - Default-deny policies, ingress from same tenant only

### Example Tenant: xonery

**Resource Quotas** (`tenants/xonery/tenant.yaml`):
- Max namespaces: 10
- CPU requests: 4 cores, limits: 8 cores
- Memory requests: 8Gi, limits: 16Gi
- Container defaults: 100m CPU, 128Mi RAM

**Network Policies**:
- Egress: Allow all (except cloud metadata: `169.254.169.254/32`)
- Ingress: Only from same tenant (`capsule.clastix.io/tenant: xonery`)

**Gateway** (`tenants/xonery/gateway.yaml`):
- Namespace: `xonery-gateway`
- Listeners: HTTP (80), HTTPS (443)
- TLS: Wildcard certificate `*.xonery.local` (cert-manager)
- Routes: Scoped to tenant namespaces only

**Apps** (`tenants/xonery/apps.yaml`):
- External repo: `https://github.com/stupside/apps`
- Auto-sync: Every 30m
- Prune: Enabled

### Adding a New Tenant

1. **Create tenant directory**:
   ```bash
   mkdir -p tenants/newtenant
   ```

2. **Copy and modify tenant definition**:
   ```bash
   cp tenants/xonery/tenant.yaml tenants/newtenant/tenant.yaml
   # Edit: Update tenant name, quotas, owners
   ```

3. **Create Gateway** (optional):
   ```bash
   cp tenants/xonery/gateway.yaml tenants/newtenant/gateway.yaml
   # Edit: Update namespace, hostname, tenant label
   ```

4. **Create apps GitRepository**:
   ```bash
   cp tenants/xonery/apps.yaml tenants/newtenant/apps.yaml
   # Edit: Update GitRepository URL, serviceAccountName
   ```

5. **Create kustomization**:
   ```bash
   cat > tenants/newtenant/kustomization.yaml <<EOF
   apiVersion: kustomize.config.k8s.io/v1beta1
   kind: Kustomization
   resources:
     - tenant.yaml
     - gateway.yaml
     - apps.yaml
   EOF
   ```

6. **Update tenants kustomization**:
   ```bash
   # Edit tenants/kustomization.yaml, add:
   # - newtenant
   ```

7. **Commit and push**:
   ```bash
   git add tenants/newtenant
   git commit -m "Add newtenant tenant"
   git push
   ```

---

## Day 2 Operations

### Monitoring FluxCD

```bash
# Check all Kustomizations
flux get kustomizations

# Check all HelmReleases
flux get helmreleases -A

# Check source sync status
flux get sources git

# View events
flux events --for Kustomization/configs
```

### Force Reconciliation

```bash
# Reconcile specific Kustomization
flux reconcile kustomization configs --with-source

# Reconcile HelmRelease
flux reconcile helmrelease cilium -n cilium

# Reconcile everything
flux reconcile kustomization flux-system --with-source
```

### Suspend/Resume Resources

```bash
# Suspend auto-reconciliation
flux suspend kustomization tenants

# Resume
flux resume kustomization tenants
```

### Debugging

```bash
# Check kustomize-controller logs
kubectl logs -n flux-system deploy/kustomize-controller -f

# Check SOPS decryption issues
kubectl describe kustomization configs -n flux-system

# Check HelmRelease issues
kubectl describe hr cilium -n cilium
```

### Updating Components

Component versions are pinned using semantic versioning:

```yaml
# Example: infrastructure/controllers/cilium/release.yaml
spec:
  chart:
    spec:
      version: "1.17.x"  # Updates to latest 1.17.z automatically
```

To update to a new major/minor version:
1. Edit `release.yaml` and change version
2. Commit and push
3. FluxCD will automatically upgrade the HelmRelease

---

## Security

### Current Security Posture

| Feature | Status | Implementation |
|---------|--------|----------------|
| Secret Encryption | ✅ Enabled | SOPS with age |
| RBAC | ⚠️ Permissive | cluster-admin used (improvement planned) |
| Network Policies | ⚠️ Partial | Tenant isolation only (infrastructure planned) |
| Pod Security | ❌ Not enforced | Kyverno policies planned |
| Image Scanning | ❌ Not configured | Planned |
| Audit Logging | ❓ Unknown | Depends on cluster |

### Security Roadmap

**Phase 2 (Planned): RBAC Hardening**
- Replace cluster-admin with least-privilege ClusterRoles
- Create tenant-scoped ServiceAccounts
- Scope infrastructure controller permissions

**Phase 3 (Planned): Kyverno Security Policies**
- Block privileged containers
- Enforce security contexts
- Restrict allowed registries
- Require resource limits
- Validate tenant isolation

**Phase 4 (Planned): Network Policies**
- Add NetworkPolicies to all infrastructure namespaces
- Restrict lateral movement
- Block cloud metadata access everywhere

### Secrets Management Best Practices

1. **Never commit unencrypted secrets** - Always use SOPS
2. **Backup age private key** - Store in multiple secure locations
3. **Rotate keys periodically** - Re-encrypt with new age key
4. **Limit age key access** - Only platform administrators
5. **Audit secret access** - Monitor SOPS usage

---

## Troubleshooting

### FluxCD Not Syncing

```bash
# Check source
flux get sources git flux-system

# Check reconciliation errors
kubectl describe kustomization flux-system -n flux-system

# Force reconcile
flux reconcile source git flux-system
```

### SOPS Decryption Failures

```bash
# Verify sops-age secret exists
kubectl get secret sops-age -n flux-system

# Check age key is correct
kubectl get secret sops-age -n flux-system -o jsonpath='{.data.age\.agekey}' | base64 -d

# Check kustomization has decryption config
kubectl get kustomization configs -n flux-system -o yaml | grep -A 3 decryption
```

### Cilium Network Issues

```bash
# Check Cilium status
kubectl exec -n cilium ds/cilium -- cilium status

# Check connectivity
kubectl exec -n cilium ds/cilium -- cilium connectivity test

# View Hubble flows
kubectl port-forward -n cilium svc/hubble-ui 12000:80
# Open http://localhost:12000
```

### Certificate Issues

```bash
# Check ClusterIssuers
kubectl get clusterissuer

# Check certificates
kubectl get certificate -A

# Describe certificate for details
kubectl describe certificate <name> -n <namespace>
```

---

## Backup & Disaster Recovery

### Backup age Private Key

The age private key is **critical** for decrypting secrets. Backup strategies:

1. **Password Manager**: Store in 1Password, Bitwarden, etc.
2. **Encrypted Cloud Storage**: Upload encrypted `age.agekey`
3. **Paper Backup**: Print QR code for offline storage
4. **Team Backup**: Share with trusted team members (encrypted)

### Cluster State Backup (Recommended)

Use Velero for cluster-wide backups:

```bash
# Install Velero
# https://velero.io/docs/main/basic-install/

# Backup cluster
velero backup create cluster-backup

# Backup specific namespace
velero backup create tenant-backup --include-namespaces=xonery-gateway
```

### Disaster Recovery

In case of complete cluster loss:

1. **Rebuild k3s cluster** (Step 1 in Initial Setup)
2. **Bootstrap FluxCD** (Step 2)
3. **Restore age private key** from backup
4. **Create sops-age secret** (Step 3.2)
5. **FluxCD auto-deploys everything** from Git

All infrastructure and tenant configurations are in Git - FluxCD will restore automatically.

---

## Contributing

### Making Changes

1. Create feature branch
2. Make changes to YAML files
3. Test locally: `kustomize build clusters/ | kubectl apply --dry-run=server -f -`
4. Commit with conventional commits format
5. Push and create PR
6. FluxCD auto-applies after merge to main

### Commit Message Format

```
<type>(<scope>): <description>

[optional body]

🤖 Generated with Claude Code
Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

**Types**: `feat`, `fix`, `docs`, `refactor`, `chore`, `security`
**Scopes**: `flux`, `cilium`, `cert-manager`, `capsule`, `kyverno`, `tenants`, `secrets`, `rbac`, `network`

---

## Support

- **FluxCD Documentation**: https://fluxcd.io/
- **Cilium Documentation**: https://docs.cilium.io/
- **SOPS Documentation**: https://github.com/getsops/sops
- **Gateway API**: https://gateway-api.sigs.k8s.io/
- **Capsule**: https://capsule.clastix.io/

---

## License

[Add your license here]

## Maintainers

[Add maintainer information]
