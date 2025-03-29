#!/bin/bash

#Update packages
sudo dnf -y update

#Install SSM Agents
sudo dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl enable amazon-ssm-agent

#Download and install CloudWatch Agents
sudo dnf install -y https://amazoncloudwatch-agent.s3.amazonaws.com/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
systemctl start amazon-cloudwatch-agent
systemctl enable amazon-cloudwatch-agent

#Download the app.js and package.json from the GitHub repo
curl -o app.js https://raw.github.com/aws-all-star/aws-labs/main/LAB2/app.js
curl -o package.json https://raw.github.com/aws-all-star/aws-labs/main/LAB2/package.json

#Install dependencies
dnf install https://download.rockylinux.org/pub/rocky/9.5/devel/x86_64/os/Packages/r/redhat-lsb-4.1-56.el9.x86_64.rpm -y
sudo dnf install -y dirmngr ca-certificates

#Add the NodeSource repository's signing key
curl -sL https://rpm.nodesource.com/gpgkey/nodesource.gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/nodesource.gpg

#Update packages again
sudo dnf -y update

#Install Node.js 20.x LTS
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo dnf install nodejs -y

#install npm v9
sudo npm install -y -g npm@9.7.1

#Install npm
npm install

#Set the application variables
#MUDAR IP DA MAQUINA
export TESTDB_HOST="testdb"
export DB_HOST="10.0.10.10"
export DB_PORT="27017"
export DB_NAME="lab2"

#Start the application
npm start
