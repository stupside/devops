curl -s https://fluxcd.io/install.sh | FLUX_VERSION=2.2.3 sudo bash

flux bootstrap github --owner=stupside --repository=devops --branch=main --path=/kubernetes/clusters/dev