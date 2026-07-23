.PHONY: help start stop restart status doctor build deploy clean

help:
	@echo "==============================="
	@echo " Qualibytes DevOps Commands"
	@echo "==============================="
	@echo "make start      - Start complete local environment"
	@echo "make stop       - Stop complete local environment"
	@echo "make restart    - Restart environment"
	@echo "make doctor     - Check dependencies"
	@echo "make status     - Cluster status"
	@echo "make build      - Build Docker images"
	@echo "make deploy     - Deploy application"
	@echo "make clean      - Cleanup docker"

doctor:
	bash automation/check-prerequisites.sh

start:
    bash automation/check-prerequisites.sh
    bash kind/create-cluster.sh
    bash kind/install-addons.sh
    bash automation/build-images.sh
    bash automation/load-images.sh
    bash automation/deploy-kind.sh
    bash automation/deploy-monitoring.sh
    bash automation/install-argocd.sh
    bash automation/health-check.sh

stop:
    bash automation/remove-argocd.sh
    bash automation/delete-monitoring.sh
    bash automation/destroy-kind.sh
    bash kind/delete-cluster.sh
restart: stop start

status:
	kubectl get nodes
	kubectl get pods -A

build:
	bash automation/build-images.sh

deploy:
	bash automation/deploy-kind.sh
	TARGET=kind bash automation/deploy-kind.sh
	TARGET=eks bash automation/deploy-eks.sh

clean:
	docker system prune -f
