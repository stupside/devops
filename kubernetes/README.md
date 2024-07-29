# The setup pipeline

- Ansible to setup the Vagrant and Kubernetes Master.
- Vagrant to deploy cluster VMs.
- ~~Terraform to provision an OCI server (bonus)~~

The clusters folder contains de clusters that must be deployed.

/clusters -> The fluxcd clusters

# The k8s stack

- Klipper LB
- Nginx Ingress
- Fluxcd and Flagger
- Cert Manager avec Lets Encrypt

# Architecture fluxcd

## Folder /apps/environments/<env>

Contains the applications managed by the desired environment.

### Folder /apps/environments/<env>/<application>

Contains the _Kubernetes_ manifest to configure the desired application

**/apps/environments/<env>/<application>/release.yaml**

**/apps/environments/<env>/<application>/repository.yaml**

**/apps/environments/<env>/<application>/network/ingress.yaml**

## Folder /apps/clusters

Contains fluxcd manifest. Most importantly contains the file **apps.yaml**.

### File /apps/clusters/apps.yaml

Contains entries telling where fluxcd looks for applications to deploy. Each entries should point to a git repository path for such as **/apps/environments/<env>**

# Development of the UI to manage fluxcd

## Pour créer un nouveau cluster

1. Création d’une branche git **origin/environments/<env>**
2. Ajout d’une entrée dans **clusters/apps.yaml**
3. Ajout d’un dossier dans **apps/environments/<env>** avec un README.md
4. Appliquer la config Vagrant et provisioner la VM avec _fluxcd_
   1. Connection au repository git _sur la branche_ **origin/environments/<env>**
   2. Création d’un tenant **<env>**

## Management d’une application

### Création

Parameters: name, network((domain, subdomain, path, protocole, port)[]), repository(kind, url), release(version), …values

1. Création de l’architecture de fichier

   **/apps/environments/<env>/<application>/release.yaml**

   **/apps/environments/<env>/<application>/repository.yaml**

   **/apps/environments/<env>/<application>/network/ingress.yaml**

2. Application des templates
3. Push sur la branch **origin/environments/<env>**

### Mise à jour

Parse des fichiers manifests sur la branche **origin/environments/<env>**

**/apps/environments/<env>/<application>/release.yaml**

**/apps/environments/<env>/<application>/repository.yaml**

**/apps/environments/<env>/<application>/network/ingress.yaml**

### Suppression

Suppression des fichiers dans **origin/environments/<env>/<application>**
