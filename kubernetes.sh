curl -s https://fluxcd.io/install.sh | FLUX_VERSION=2.4.0 bash

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

flux bootstrap github --personal --token-auth $GIT_REPO_TOKEN \
    --owner=$GIT_REPO_OWNER \
    --repository=$GIT_REPO_NAME \
    --path=/kubernetes/clusters/$CLUSTER \