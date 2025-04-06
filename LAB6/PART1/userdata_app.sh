#!/bin/bash
#lab-6 application scripts
#created by Donghyun, Kim
#KT DS, Cloud Consulting Team, Team Manager

#Update packages
sudo dnf -y update

#Download the app.js and package.json from the GitHub repo
curl -o app.js https://raw.githubusercontent.com/aws-all-star/aws-labs/refs/heads/main/LAB2/app.js
curl -o package.json https://raw.githubusercontent.com/aws-all-star/aws-labs/refs/heads/main/LAB2/package.json

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
export TESTDB_HOST="testdb"
export DB_HOST="10.0.10.10"
export DB_PORT="27017"
export DB_NAME="lab2"

#Start the application
npm start
