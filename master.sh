#! /bin/bash

# Exit the script if erorr occurs

set -e

# Set hostname for the Kubernetes control-plane node
sudo hostnamectl set-hostname master

# Update system packages
sudo apt update && sudo apt upgrade -y


# Disable swap (Kubernetes does not work with swap enabled)
sudo swapoff -a

# Make swap disable permanent
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab


# Load kernel modules required for container and pod networking
# overlay     : needed by container runtimes to manage container filesystems
# br_netfilter: allows Kubernetes to see and control pod network traffic via iptables
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

# Load the modules now (no reboot required)
sudo modprobe overlay
sudo modprobe br_netfilter


# Kernel settings required for Kubernetes networking to work correctly
# These ensure traffic between pods and services is properly forwarded and filtered
sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Apply kernel parameter changes
sudo sysctl --system


# Install basic tools needed to add repositories securely
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates


# Add Docker GPG key (containerd is provided via Docker repository)
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg

# Add Docker repository
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"


# Install containerd (container runtime used by Kubernetes)
sudo apt update
sudo apt install -y containerd.io


# Create default containerd configuration
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1

# Use systemd cgroups (recommended for kubelet compatibility)
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

# Restart and enable containerd
sudo systemctl restart containerd
sudo systemctl enable containerd


# Add Kubernetes official repository
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /" \
| sudo tee /etc/apt/sources.list.d/kubernetes.list

# Add Kubernetes GPG key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Install Kubernetes components
sudo apt update
sudo apt install -y kubelet kubeadm kubectl

# Prevent automatic Kubernetes upgrades
sudo apt-mark hold kubelet kubeadm kubectl

# Enable kubelet to start automatically on reboot
sudo systemctl enable kubelet


# Initialize Kubernetes control-plane and show detailed logs for debugging
# Pod CIDR matches Flannel network
sudo kubeadm init --pod-network-cidr=10.244.0.0/16  



