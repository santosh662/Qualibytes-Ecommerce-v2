#!/usr/bin/env bash

###############################################################################
# Qualibytes Automation Framework v2
# Install Jenkins
###############################################################################

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

source "${PROJECT_ROOT}/automation/common.sh"

banner "Installing Jenkins"

if systemctl is-active --quiet jenkins
then
    success "Jenkins already installed and running."
    exit 0
fi

###############################################################################
# Java
###############################################################################

if command_exists java
then

    success "Java already installed."

else

    info "Installing Java..."

    sudo apt-get update

    sudo apt-get install -y \
        fontconfig \
        openjdk-21-jdk

    success "Java Installed."

fi

###############################################################################
# Jenkins Installed .deb based
###############################################################################

if systemctl list-unit-files | grep -q "^jenkins.service"
then

    success "Jenkins already installed."

else

    line

    info "Downloading Jenkins Package..."

    wget -O /tmp/jenkins.deb \
    https://get.jenkins.io/debian-stable/jenkins_2.516.3_all.deb

    success "Download Complete."

    line

    info "Installing Jenkins..."

    sudo dpkg -i /tmp/jenkins.deb || true

    info "Installing Missing Dependencies..."

    sudo apt-get update

    sudo apt-get install -f -y

    success "Jenkins Installed."

fi

###############################################################################
# Configure Jenkins Port
###############################################################################

line

info "Configuring Jenkins Port..."

sudo mkdir -p /etc/systemd/system/jenkins.service.d

sudo tee /etc/systemd/system/jenkins.service.d/override.conf >/dev/null <<EOF
[Service]
Environment="JENKINS_PORT=8082"
EOF

sudo systemctl daemon-reload

success "Jenkins configured on port 8082."

###############################################################################
# Enable Jenkins
###############################################################################

line

info "Enabling Jenkins..."

sudo systemctl enable jenkins

success "Jenkins Enabled."

###############################################################################
# Start Jenkins
###############################################################################

line

info "Starting Jenkins..."

sudo systemctl restart jenkins

###############################################################################
# Wait For Jenkins
###############################################################################

line

info "Waiting for Jenkins..."

COUNT=0

until systemctl is-active --quiet jenkins
do

    COUNT=$((COUNT+1))

    if [[ $COUNT -gt 20 ]]
    then

        error "Jenkins failed to start."

        exit 1

    fi

    sleep 3

done

success "Jenkins Running."

###############################################################################
# Verify Port
###############################################################################

line

info "Verifying Jenkins Port..."

sleep 5

if ss -tuln | grep -q ":8082 "
then

    success "Jenkins is listening on port 8082."

else

    warning "Port verification skipped."

fi

################################################
# Docker permission
################################################
if groups jenkins | grep -q docker; then
    success "Docker permission already exists."
else
    info "Adding Jenkins to Docker group..."
    sudo usermod -aG docker jenkins
    success "Docker permission added."
fi


############################################################
# kubeconfig Copy
# ##########################################################
info "Configuring Kubernetes Access..."

sudo mkdir -p /var/lib/jenkins/.kube

if [ -f "$HOME/.kube/config" ]; then

    sudo cp "$HOME/.kube/config" /var/lib/jenkins/.kube/config

    sudo chown -R jenkins:jenkins /var/lib/jenkins/.kube

    sudo chmod 700 /var/lib/jenkins/.kube

    sudo chmod 600 /var/lib/jenkins/.kube/config

    success "Kubeconfig configured."

else

    warning "No kubeconfig found."

fi


################################################################################# Restart jenkins
################################################################################
info "Restarting Jenkins..."

sudo systemctl restart jenkins

sleep 5

success "Jenkins Restarted."

########################################################################
# Verfiy Docker
# #######################################################################

info "Verifying Docker Access..."

sudo -u jenkins docker version >/dev/null 2>&1

if [ $? -eq 0 ]; then
    success "Docker access verified."
else
    warning "Docker access could not be verified."
fi


###############################################################################
# Verfiy kubectl
# ############################################################################
info "Verifying Kubernetes Access..."

sudo -u jenkins kubectl get nodes >/dev/null 2>&1

if [ $? -eq 0 ]; then
    success "kubectl access verified."
else
    warning "kubectl access could not be verified."
fi


###############################################################################
# Initial Password
###############################################################################

line

PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)

PUBLIC_IP=$(curl -s ifconfig.me)

echo
echo "============================================================"
echo " Jenkins Installed Successfully"
echo "============================================================"
echo
echo "Jenkins URL"
echo "http://${PUBLIC_IP}:8082"
echo
echo "Initial Password"
echo "${PASSWORD}"
echo

completed "Jenkins Ready."

