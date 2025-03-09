#!/bin/bash
#linux-ec2-server
#created by Donghyun, Kim
#KT DS, Cloud Consulting Team, Team Manager

REGION="ap-northeast-2"
SUBNET_PUBLIC_AZ="ap-northeast-2a"

#Create VPC
VPC_ID=$(aws ec2 create-vpc \
--cidr-block 10.0.0.0/16 \
--tag-specification 'ResourceType=vpc,Tags=[{Key=Name,Value=vpc_lab1}, {Key=project,Value=labs}]' \
--region $REGION \
--output text \
--query 'Vpc.VpcId')

echo "VPC $VPC_ID created successfully."

#Create Internet Gateway
IGW_ID=$(aws ec2 create-internet-gateway \
--tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=igw-lab1}, {Key=project,Value=labs}]' \
--output text \
--query 'InternetGateway.InternetGatewayId')

echo "IGW $IGW_ID created successfully."

#Attach Internet Gateway to VPC
aws ec2 attach-internet-gateway \
--internet-gateway-id $IGW_ID \
--vpc-id $VPC_ID

echo "IGW $IGW_ID successfully attached to VPC $VPC_ID."

#Create public subnet
SUBNET_ID=$(aws ec2 create-subnet \
--vpc-id $VPC_ID \
--cidr-block 10.0.0.0/24 \
--tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=subnet_lab1}, {Key=project,Value=labs}]' \
--availability-zone $SUBNET_PUBLIC_AZ \
--region $REGION \
--output text \
--query 'Subnet.SubnetId')

echo "Subnet $SUBNET_ID created successfully."

#Enable subnet to auto-assign public IP
aws ec2 modify-subnet-attribute --subnet-id $SUBNET_ID --map-public-ip-on-launch
echo "Public IP auto-assign enabled successfully."

#Create route table
RT_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --output text --query 'RouteTable.RouteTableId' \
--tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=rt_lab1}, {Key=project,Value=labs}]')

echo "Route Table $RT_ID created successfully."

#Create route to internet gateway
aws ec2 create-route --route-table-id $RT_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID

echo "Route to the IGW $IGW_ID created successfully."

#Associate the subnet with the route table
aws ec2 associate-route-table --subnet-id $SUBNET_ID --route-table-id $RT_ID

echo "Subnet $SUBNET_ID associated with route table $RT_ID."

#Create security group
SG_ID=$(aws ec2 create-security-group \
    --group-name lab1_sg \
    --description "SG to allow SSH Access" \
    --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=sg_lab1}, {Key=project,Value=labs}]' \
    --vpc-id $VPC_ID \
    --output text \
    --query 'GroupId')

echo "Security group $SG_ID created successfully."


#Enable the security group to allow SSH and ICMP access
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol icmp --port -1 --source-group $SG_ID
echo "Security group $SG_ID authorized for SSH and ICMP ingress."

#Create key-pair
aws ec2 create-key-pair \
--key-name lab1_key \
--key-type rsa \
--query 'KeyMaterial' \
--output text \
> lab1_key.pem 

echo "Key-pair 'lab1_key.pem' created successfully." 

#Create EC2 Instance server1 node
SERVER_NODE1=$(aws ec2 run-instances \
    --image-id ami-0b39b65eacb043ba3 \
    --count 1 \
    --instance-type t2.small \
    --key-name lab1_key \
    --subnet-id $SUBNET_ID \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=server1}, {Key=project,Value=labs}]' \
    --security-group-ids $SG_ID \
    --output text \
    --query 'Instances[0].InstanceId')

echo "Instance Server1 Node $SERVER_NODE1 created successfully."

#Create EC2 Instance station1 node
STATION_NODE1=$(aws ec2 run-instances \
    --image-id ami-0b39b65eacb043ba3 \
    --count 1 \
    --instance-type t2.micro \
    --key-name lab1_key \
    --subnet-id $SUBNET_ID \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=station1}, {Key=project,Value=labs}]' \
    --security-group-ids $SG_ID \
    --output text \
    --query 'Instances[0].InstanceId')

echo "Instance Station1 Node $STATION_NODE1 created successfully."
