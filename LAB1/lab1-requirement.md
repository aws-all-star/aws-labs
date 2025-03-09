# 1. 준비하기
이 LAB 에서 AWS CLI 명령줄 도구와 Bash Shell 스크립트를 사용하여 AWS 클라우드 인프라를 배포합니다. AWS 클라우드 환경에는 VPC, 인터넷 게이트웨이, 공용 서브넷, 공용 경로 테이블 및 세 개의 EC2 인스턴스가 있습니다. 
EC2 인스턴스는 동일한 공용 서브넷과 VPC에 있어야 하며, 서로 연결할 수 있어야 하며, SSH로 원격으로 액세스할 수 있어야 합니다. 또한 인스턴스에는 Python 3.10, Node 18.0, Java 11.0 및 Docker 엔진이 설치되어 있어야 합니다.
<br/><br/>

AWS CLI 도구를 활용하여 다음과 예시를 참고하여 클라우드 아키텍처를 생성하고 설정하는 명령어를 실행합니다.<br/>
리전(REGION)은 ap-northeast-2(Seoul) 에 있는 자원만 활용하고 가용 영역(Availability Zones) 은 'ap-northeast-2a' 반드시 존재해야 합니다.

## 2. 시작하기
1. 리전(REGION)은 ap-northeast-2(Seoul) 에 있는 자원만 활용하고 가용 영역(Availability Zones) 은 'ap-northeast-2a' 반드시 존재해야 합니다.
```sh
REGION="ap-northeast-2"
SUBNET_PUBLIC_AZ="ap-northeast-2a"
```
<br/>

2. '10.0.0.0/16' CIDR 블록을 가진, VPC를 생성합니다. tag는 `key=Name ,value=vpc_lab1` 설정합니다.
```sh
VPC_ID=$(aws ec2 create-vpc \
--cidr-block 10.0.0.0/16 \
--tag-specification 'ResourceType=vpc,Tags=[{Key=Name,Value=vpc_lab1}, {Key=project,Value=labs}]' \
--region $REGION \
--output text \
--query 'Vpc.VpcId')
```
<br/>
   
3. VPC에 인터넷 게이트웨이 연결되어야 합니다. tag는 `key=Name ,value=igw_lab1` 설정합니다.
```sh
IGW_ID=$(aws ec2 create-internet-gateway \
--tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=igw-lab1}, {Key=project,Value=labs}]' \
--output text \
--query 'InternetGateway.InternetGatewayId')
```
<br/>
   
4. Public subnet 에서 Public IP 자동 할당하도록 되어야 합니다.
```sh
aws ec2 attach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
```
<br/>
   
5. `10.0.0.0/24` 서브넷을 가진, Public Subnet 를 생성합니다. tag는 `key=Name ,value=subnet_lab1` 설정합니다.
```sh
SUBNET_ID=$(aws ec2 create-subnet \
--vpc-id $VPC_ID \
--cidr-block 10.0.0.0/24 \
--tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=subnet_lab1}, {Key=project,Value=labs}]' \
--availability-zone $SUBNET_PUBLIC_AZ \
--region $REGION \
--output text \
--query 'Subnet.SubnetId')
```
<br/>

6. Public IP가 자동으로 서브넷에 할당되도록 합니다.
```sh
aws ec2 modify-subnet-attribute --subnet-id $SUBNET_ID --map-public-ip-on-launch
```
<br/>

7. 경로 테이블(route table)을 생성합니다. 그리고 인터넷 게이트웨이에 추가합니다.
```sh
RT_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --output text --query 'RouteTable.RouteTableId' \
--tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=rt_lab1}, {Key=project,Value=labs}]')
```
<br/>
```sh
aws ec2 create-route --route-table-id $RT_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID
```
<br/>

8. Public subnet을 Public 경로 테이블(route table)과 연결해야 합니다.
```sh
aws ec2 associate-route-table --subnet-id $SUBNET_ID --route-table-id $RT_ID
```
<br/>

9. `lab1_sg` 이름을 가진 보안 그룹(Security Group)을 생성합니다. 이 보안 그룹은 SSH(Secure Shell) 가능해야 합니다.
```sh
SG_ID=$(aws ec2 create-security-group \
    --group-name lab1_sg \
    --description "SG to allow SSH Access" \
    --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=sg_lab1}, {Key=project,Value=labs}]' \
    --vpc-id $VPC_ID \
    --output text \
    --query 'GroupId')
```
<br/>

10. 이 보안 그룹은 SSH(Secure Shell) 가능해야 합니다.
```sh
aws ec2 authorize-security-group-ingress --group-id <SG_ID> --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id <SG_ID> --protocol icmp --port -1 --source-group $SG_ID
```
<br/>

11. EC2 인스턴스 접근하기 위한 `lab1_key` 이름을 가진 key-pair(키 페어)를 생성합니다.
```sh
aws ec2 create-key-pair --key-name lab1_key \
--key-type rsa \
--query 'KeyMaterial' \
--output text \
> lab1_key.pem
```
<br/>

12. server1과 station1 이름을 가진 EC2 인스턴스 2개를 생성합니다. 해당 인스턴스는 임의로 가공된 AMI(rocky linux 9 update 5)를 사용해야 합니다.
```sh
SERVER_NODE1=$(aws ec2 run-instances \
    --image-id <ami-사용자 임의 AMI ID> \
    --count 1 \
    --instance-type t2.small \
    --key-name lab1_key \
    --subnet-id $SUBNET_ID \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=server1}, {Key=project,Value=labs}]' \
    --security-group-ids $SG_ID \
    --output text \
    --query 'Instances[0].InstanceId')
```
<br/>

```sh
STATION_NODE1=$(aws ec2 run-instances \
    --image-id <ami-사용자 임의 AMI ID> \
    --count 1 \
    --instance-type t2.micro \
    --key-name lab1_key \
    --subnet-id $SUBNET_ID \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=station1}, {Key=project,Value=labs}]' \
    --security-group-ids $SG_ID \
    --output text \
    --query 'Instances[0].InstanceId')
```
<br/>

