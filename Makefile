.PHONY: help setup bootstrap doctor start stop restart status build deploy clean logs

SHELL := /bin/bash

GREEN=\033[0;32m
BLUE=\033[0;34m
YELLOW=\033[1;33m
RED=\033[0;31m
NC=\033[0m

help:
	@echo ""
	@echo "==============================================="
	@echo "        Qualibytes DevOps Automation"
	@echo "==============================================="
	@echo ""
	@echo "make setup      -> Complete First Time Setup"
	@echo "make bootstrap  -> Install Required Tools"
	@echo "make doctor     -> Check Environment"
	@echo "make start      -> Start Complete Platform"
	@echo "make stop       -> Stop Everything"
	@echo "make restart    -> Restart Platform"
	@echo "make status     -> Kubernetes Status"
	@echo "make build      -> Build Docker Images"
	@echo "make deploy     -> Deploy Application"
	@echo "make clean      -> Cleanup Docker"
	@echo "make logs       -> Show All Pods"
	@echo ""

#################################################
# FIRST TIME SETUP
#################################################

setup:
	@echo ""
	@echo "======================================"
	@echo " First Time Environment Setup"
	@echo "======================================"
	@bash automation/bootstrap.sh

	@echo ""
	@echo "Running Environment Verification..."
	@bash automation/check-prerequisites.sh

	@echo ""
	@echo "Starting Platform..."
	@$(MAKE) start

#################################################
# INSTALLATION
#################################################

bootstrap:
	@bash automation/bootstrap.sh

doctor:
	@bash automation/check-prerequisites.sh

#################################################
# START PLATFORM
#################################################

start:
	@echo ""

	@echo "======================================"
	@echo " Starting Qualibytes Platform"
	@echo "======================================"

	@bash automation/check-prerequisites.sh

	@bash automation/create-cluster.sh

	@bash kind/install-addons.sh

	@bash automation/jenkins/install-jenkins.sh     

	@bash automation/build-images.sh

	@bash automation/load-images.sh

	@bash automation/deploy-kind.sh

	@bash automation/deploy-monitoring.sh

	@bash automation/install-argocd.sh

	@bash automation/health-check.sh

	@bash automation/start-portforward.sh

	@echo ""
	@echo "======================================"
	@echo " Platform Started Successfully"
	@echo "======================================"

#################################################
# STOP
#################################################

stop:
	@echo ""
	@echo "Stopping Platform..."

	-@bash automation/remove-argocd.sh
	-@bash automation/delete-monitoring.sh
	-@bash automation/destroy-kind.sh
	-@bash automation/delete-cluster.sh

	@echo ""
	@echo "Platform Stopped."

#################################################
# RESTART
#################################################

restart:
	@$(MAKE) stop
	@$(MAKE) start

#################################################
# STATUS
#################################################

status:
	@echo ""
	@echo "Nodes"
	@kubectl get nodes || true

	@echo ""
	@echo "Pods"
	@kubectl get pods -A || true

#################################################
# BUILD
#################################################

build:
	@bash automation/build-images.sh

#################################################
# DEPLOY
#################################################

deploy:
	@TARGET=kind bash automation/deploy-kind.sh

#################################################
# LOGS
#################################################

logs:
	@kubectl get pods -A

#################################################
# CLEAN
#################################################

clean:
	@echo ""
	@echo "Cleaning Docker..."

	-docker system prune -af
	-docker volume prune -f

	@echo "Done."
