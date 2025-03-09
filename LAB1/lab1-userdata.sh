#!/bin/bash
#lab-userdata scripts
#created by Donghyun, Kim
#KT DS, Cloud Consulting Team, Team Manager

#Update and upgrade packages
sudo dnf -y update

#Install SSM Agents
sudo dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl enable amazon-ssm-agent

#Download and install CloudWatch Agents
sudo dnf install -y https://amazoncloudwatch-agent.s3.amazonaws.com/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
systemctl start amazon-cloudwatch-agent
systemctl enable amazon-cloudwatch-agent
