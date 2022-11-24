.SILENT:
.PHONY: vote

help:
	{ grep --extended-regexp '^[a-zA-Z_-]+:.*#[[:space:]].*$$' $(MAKEFILE_LIST) || true; } \
	| awk 'BEGIN { FS = ":.*#[[:space:]]*" } { printf "\033[1;32m%-22s\033[0m%s\n", $$1, $$2 }'

env-create: # 1) create .env file + install stern
	./make.sh env-create

pg: # 2) run postgres alpine docker image
	./make.sh pg

seed: # 2) seed postgres instance
	./make.sh seed

vote: # 2) run vote website using npm - dev mode
	./make.sh vote

terraform-init: # 3) terraform init (updgrade) + validate
	./make.sh terraform-init

infra-create: # 3) terraform create ecr repo + ssh key
	./make.sh infra-create

build-ecr-push: # 3) build + push docker image to ecr
	./make.sh build-ecr-push

kind-argocd-create: # 4) setup kind + argocd + image updater
	./make.sh kind-argocd-create

secrets-create: # 4) create namespaces + secrets
	./make.sh secrets-create

templates-create: # 4) create files using templates
	./make.sh templates-create

argocd-open: # 5) open argocd (website)
	./make.sh argocd-open

argocd-login: # 5) argocd login (terminal)
	./make.sh argocd-login

watch-logs: # 6) watch logs using stern
	./make.sh watch-logs

watch-all: # 6) watch all within namespace
	./make.sh watch-all

watch-pods: # 6) watch pods using kubectl
	./make.sh watch-pods

watch-events: # 6) watch events using kubectl
	./make.sh watch-events

app-no-sync-create: # 6) create app (no sync)
	./make.sh app-no-sync-create

app-no-sync-destroy: # 6) destroy app (no sync)
	./make.sh app-no-sync-destroy

app-sync-create: # 6) create app (with sync-wave)
	./make.sh app-sync-create

app-sync-destroy: # 6) destroy app (with sync-wave)
	./make.sh app-sync-destroy

kind-argocd-destroy: # 7) terraform destroy kind + argocd
	./make.sh kind-argocd-destroy

infra-destroy: # 7) terraform destroy ecr repo + ssh key
	./make.sh infra-destroy

secrets-destroy: # 7) terraform destroy secrets
	./make.sh secrets-destroy

# terraform-destroy: # 8) terraform destroy all
# 	./make.sh terraform-destroy