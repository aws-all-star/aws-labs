#!/bin/bash
#lab-2 userdata scripts
#created by Donghyun, Kim
#KT DS, Cloud Consulting Team, Team Manager

#Update packages
sudo dnf -y update

#Install SSM Agents
sudo dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl enable amazon-ssm-agent

#Download and install CloudWatch Agents
sudo dnf install -y https://amazoncloudwatch-agent.s3.amazonaws.com/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
systemctl start amazon-cloudwatch-agent
systemctl enable amazon-cloudwatch-agent

# Create a MongoDB repository file(Import the MongoDB GPG public key)
echo "
[mongodb-org-8.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/9/mongodb-org/8.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://pgp.mongodb.com/server-8.0.asc
" >> /etc/yum.repos.d/mongodb-org-8.0.repo

# Install Node.js and npm
curl -sL https://rpm.nodesource.com/setup_18.x | sudo -E bash -
sudo dnf install -y nodejs

# Install MongoDB
sudo dnf install -y mongodb-org

#Download the csv file from the GitHub repo
curl -o KBL-Pitcher-2024.csv https://raw.github.com/aws-all-star/aws-labs/blob/main/LAB2/KBL-Pitcher-2024.csv

#Set the IP of the MongoDB host
sudo sed -i 's/127.0.0.1/10.0.10.10,127.0.0.1/g' /etc/mongod.conf

# Start the MongoDB service
sudo systemctl start mongod

# Specify the MongoDB connection details
# IP PRIVADO DA MAQUINA NO MONGO_HOST
MONGO_HOST="10.0.10.10"
MONGO_PORT="27017"
MONGO_DB="lab2"
COLLECTION_NAME="KBL_Pitcher_2024"
CSV_FILE="KBL-Pitcher-2024.csv"

# Use mongoimport to import the CSV file into the specified MongoDB collection
sudo mongoimport --host $MONGO_HOST --port $MONGO_PORT --db $MONGO_DB --collection $COLLECTION_NAME --type csv --headerline --file $CSV_FILE
