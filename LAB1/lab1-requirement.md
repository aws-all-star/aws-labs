# LAB 1. AWS 인프라 기본 구성 및 최적화
이 LAB 에서 AWS CLI 명령줄 도구와 Bash Shell 스크립트를 사용하여 AWS 클라우드 인프라를 배포합니다. AWS 클라우드 환경에는 VPC, 인터넷 게이트웨이, 공용 서브넷, 공용 경로 테이블 및 세 개의 EC2 인스턴스가 있습니다. 
EC2 인스턴스는 동일한 공용 서브넷과 VPC에 있어야 하며, 서로 연결할 수 있어야 하며, SSH로 원격으로 액세스할 수 있어야 합니다. 또한 인스턴스에는 Python 3.10, Node 18.0, Java 11.0 및 Docker 엔진이 설치되어 있어야 합니다.
<br/><br/>

AWS CLI 도구를 활용하여 다음과 예시를 참고하여 클라우드 아키텍처를 생성하고 설정하는 명령어를 실행합니다.<br/>
리전(REGION)은 ap-northeast-2(Seoul) 에 있는 자원만 활용하고 가용 영역(Availability Zones) 은 'ap-northeast-2a' 반드시 존재해야 합니다.

## 1. 요구사항

1. '10.0.0.0/16' CIDR 블록을 가진, VPC를 생성합니다. tag는 `key=Name ,value=vpc_lab1` 설정합니다.
```sh
VPC_ID=$(aws ec2 create-vpc \
--cidr-block 10.0.0.0/16 \
--tag-specification 'ResourceType=vpc,Tags=[{Key=Name,Value=vpc_lab1}, {Key=project,Value=labs}]' \
--region $REGION \
--output text \
--query 'Vpc.VpcId')
```
<br/>
   
2. VPC에 인터넷 게이트웨이 연결되어야 합니다. tag는 `key=Name ,value=igw_lab1` 설정합니다.
```sh
IGW_ID=$(aws ec2 create-internet-gateway \
--tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=igw-lab1}, {Key=project,Value=labs}]' \
--output text \
--query 'InternetGateway.InternetGatewayId')
```
<br/>
   
3. Public subnet 에서 Public IP 자동 할당하도록 되어야 합니다.
```sh
aws ec2 attach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
```
<br/>
   
4. 특정 `10.0.0.0/24` 서브넷을 가진, Public Subnet 를 생성합니다. tag는 `key=Name ,value=subnet_lab1` 설정합니다.
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

5. Public IP가 자동으로 서브넷에 할당되도록 합니다.
```sh
aws ec2 modify-subnet-attribute --subnet-id $SUBNET_ID --map-public-ip-on-launch
```
<br/>

6. 경로 테이블(route table)을 생성합니다. 그리고 인터넷 게이트웨이에 추가합니다.
```sh
RT_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --output text --query 'RouteTable.RouteTableId' \
--tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=rt_lab1}, {Key=project,Value=labs}]')
```
<br/>
```sh
aws ec2 create-route --route-table-id $RT_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID
```
<br/>

7. Public subnet을 Public 경로 테이블(route table)과 연결해야 합니다.
```sh
aws ec2 associate-route-table --subnet-id $SUBNET_ID --route-table-id $RT_ID
```
<br/>

8. `lab1_sg` 이름을 가진 보안 그룹(Security Group)을 생성합니다. 이 보안 그룹은 SSH(Secure Shell) 가능해야 합니다.
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

9. 이 보안 그룹은 SSH(Secure Shell) 가능해야 합니다.
```sh
aws ec2 authorize-security-group-ingress --group-id <SG_ID> --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id <SG_ID> --protocol icmp --port -1 --source-group $SG_ID
```
<br/>

8. EC2 인스턴스 접근하기 위한 `lab1_key` 이름을 가진 key-pair(키 페어)를 생성합니다.
```sh
aws ec2 create-key-pair --key-name lab1_key \
--key-type rsa \
--query 'KeyMaterial' \
--output text \
> lab1_key.pem
```
<br/>

9. EC2 인스턴스
   1. Master node 1
      1. 크기 : t2.small
         2. 이미지 : Rocky Linux 9.5
         3. 설치 소프트웨어
            1. Python 3.10
            2. Node 18.0
            3. Java 11.0
            4. Docker engine
         4. 태그 `key=Name ,value=master-node-01`
      2. Worker node 1
         1. 크기 : t2.micro
         2. 이미지 : Rocky Linux 9.5
         3. 설치 소프트웨어
            1. Python 3.10
            2. Node 18.0
            3. Java 11.0
            4. Docker engine
         4. Tag `key=Name ,value=worker-node-01`
      3. Worker node 2
         1. 크기 : t2.micro
         2. 이미지 : Rocky Linux 9.5
         3. 설치 소프트웨어
            1. Python 3.10
            2. Node 18.0
            3. Java 11.0
            4. Docker engine
         4. Tag `key=Name ,value=worker-node-02`
   10. 3개의 모든 인스턴스는,
      1. 모든 Linux 서버는 최신 버전의 커널과 라이브러리를 유지해야 한다.
      2. 동일한 Public 서브넷과 VPC에서,
      3. 서로 간 통신할 수 있습니다. - 예를 들어 ping 명령을 통해
      4. SSH로 원격으로 접근할 수 있고,
      5. 생성된 모든 리소스는 태그가 지정되어야 합니다.: `key=labs ,value=awscloud`
<br/><br/>

## 2. 네트워크 다이어그램
<img width="721" alt="image" src="https://github.com/user-attachments/assets/704d2fb5-179f-48e4-9865-94b08e246a24" />
<br/><br/>

## 3. 제출 지침
- 완성된 GitHub 저장소의 zip을 다운로드하세요.
- 학습 포털 프로젝트 페이지에서 인계 탭을 클릭하고 과제 업로드를 클릭하고 zip 파일을 업로드하세요.

<br/><br/>
