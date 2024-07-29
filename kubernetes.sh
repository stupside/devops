# curl -s https://fluxcd.io/install.sh | FLUX_VERSION=2.2.3 bash

flux bootstrap github --personal --token-auth $GIT_REPO_TOKEN \
    --owner=$GIT_REPO_OWNER \
    --repository=$GIT_REPO_NAME \
    --path=/kubernetes/clusters/$CLUSTER \