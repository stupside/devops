.PHONY: up down bootstrap

CLUSTER_NAME = "devops"

GITHUB_USER = "stupside"
GITHUB_BRANCH = "main"
GITHUB_REPOSITORY = "devops"

KUBERNETES_PATH = "./cluster/kubernetes"

make: down up bootstrap

up:
	kind create cluster --config kind.yaml --name=$(CLUSTER_NAME)

down:
	kind delete cluster --name=$(CLUSTER_NAME)

bootstrap:
	flux bootstrap github \
		--path=$(KUBERNETES_PATH) \
		--owner=$(GITHUB_USER) \
		--branch=$(GITHUB_BRANCH) \
		--repository=$(GITHUB_REPOSITORY) \
		--personal