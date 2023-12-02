.PHONY: k8s-install k8s-uninstall flux-bootstrap

INVENTORY ?= inventory

install:
	ansible-playbook playbooks/k8s/install.yml -i $(INVENTORY)

uninstall:
	ansible-playbook playbooks/k8s/uninstall.yml -i $(INVENTORY)

bootstrap:
	ansible-playbook playbooks/flux/bootstrap.yml -i $(INVENTORY)