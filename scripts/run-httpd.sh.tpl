#!/bin/bash

# Set up logging
LOG_FILE="/var/log/setup.log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Error handling function
handle_error() {
    echo "ERROR: $1" >&2
    exit 1
}

# Update and install necessary packages
sudo apt update -y || handle_error "Failed to update package lists"
sudo apt upgrade -y || handle_error "Failed to upgrade"
sudo apt-get install -y git unzip jq || handle_error "Failed to install required packages"
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt-get install terraform
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
# Add Docker's official GPG key:
sudo apt-get install ca-certificates curl || handle_error "failed to install certificates"
sudo install -m 0755 -d /etc/apt/keyrings || handle_error "Failed to install keyrings"
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc || handle_error "Failed to download keys"
sudo chmod a+r /etc/apt/keyrings/docker.asc || handle_error "Failed to give proper permissions"

# Add the repository to Apt sources:
CODENAME=$(grep '^VERSION_CODENAME=' /etc/os-release | cut -d= -f2)
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $CODENAME stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update || handle_error "Failed to update"

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y || handle_error "Failed to install docker"

# sudo groupadd docker || handle_error "Failed to create docker group"

sudo usermod -aG docker $USER || handle_error "Failed to add user to docker"

newgrp docker || handle_error "Failed to reload new group"

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" || handle_error "Failed to download AWS CLI"
unzip awscliv2.zip || handle_error "Failed to unzip AWS CLI"
sudo ./aws/install || handle_error "Failed to install AWS CLI"

# Install CloudWatch Agent and collectd
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
sudo apt-get update && sudo apt-get install collectd -y

# Create CloudWatch Agent config file with CPU, Memory, Disk, and Network metrics
cat <<EOF | sudo tee /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
  "agent": {
    "metrics_collection_interval": 60,
    "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/setup.log",
            "log_group_name": "/aws/ec2/setup-logs",
            "log_stream_name": "{instance_id}",
            "timestamp_format": "%Y-%m-%d %H:%M:%S"
          },
          {
            "file_path": "/var/log/apache2/access.log",
            "log_group_name": "/ecommerce/apache-access",
            "log_stream_name": "{instance_id}",
            "timestamp_format": "%d/%b/%Y:%H:%M:%S %z"
          },
          {
            "file_path": "/var/log/apache2/error.log",
            "log_group_name": "/ecommerce/apache-error",
            "log_stream_name": "{instance_id}",
            "timestamp_format": "%Y-%m-%d %H:%M:%S"
          }
        ]
      }
    }
  },
  "metrics": {
    "metrics_collected": {
      "cpu": {
        "measurement": [
          "cpu_usage_idle",
          "cpu_usage_user",
          "cpu_usage_system"
        ],
        "metrics_collection_interval": 60,
        "totalcpu": false
      },
      "disk": {
        "measurement": [
          "disk_used_percent"
        ],
        "resources": [
          "*"
        ],
        "metrics_collection_interval": 60
      },
      "mem": {
        "measurement": [
          "mem_used_percent"
        ],
        "metrics_collection_interval": 60
      },
      "net": {
        "measurement": [
          "bytes_sent",
          "bytes_recv"
        ],
        "resources": [
          "*"
        ],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF

# Start CloudWatch Agent with the new configuration
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json \
    -s || handle_error "Failed to start CloudWatch Agent"

echo "CloudWatch Agent installed and configured successfully with CPU and system metrics."

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" || handle_error "Failed to download kubectl"

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl || handle_error "Failed to install kubectl"

sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update

sudo apt-get install terraform

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3

chmod 700 get_helm.sh

./get_helm.sh

sudo groupadd docker

sudo usermod -aG docker ubuntu

newgrp docker