## 1. 준비하기
수강생은 강사의 지시에 따라 가공된 클라우드 이미지(Rocky Linux)를 제공받을 수 있습니다.
제공된 QCOW2 이미지를 RAW 이미지로 변환하기 위해서는 각 클라이언트 환경에 맞게 설치할 수 있어야 합니다.<br/>
https://www.qemu.org/download/#macos

설치가 정상적으로 완료되면 AWS에서 제공되는 VM IMPORT 기능을 통해 전환할 수 있습니다.<br/>
다만, VM Import/Export로 가져오는 리소스에 대한 요구 사항을 사전에 파악하고 지원하는 이미지 형식 또는 운영체제인지를 확인해야 합니다.<br/>
https://docs.aws.amazon.com/ko_kr/vm-import/latest/userguide/prerequisites.html
<br/>

1. QCOW2를 RAW 이미지로 변환합니다.
```sh
$ qemu-img convert rhel-guest-image-6.8-20160425.0.x86_64.qcow2 rhel-guest-image-6.8-20160425.0.x86_64.raw
```
<br/>

2. AWS S3 버킷 생성한 후, RAW이미지를 s3 버킷으로 업로드
```sh
$ aws s3api create-bucket --bucket my-ktds --region ap-northeast-2 --create-bucket-configuration LocationConstraint=ap-northeast-2
```
<br/>

```sh
$ aws s3 cp rhel-guest-image-6.8-20160425.0.x86_64.raw s3://my-ktds 
```
<br/>

3. AWS S3 권한 부여합니다.
```sh
$ aws iam create-role --role-name vmimport --assume-role-policy-document "file://trust-policy.json"
$ aws iam put-role-policy --role-name vmimport --policy-name vmimport --policy-document "file://role-policy.json"
$ aws s3api put-bucket-policy --bucket my-rhel9-img --policy "file://bucket-policy.json"
```
<br/>

4. AWS EC2 스냅샷 생성한 후 정상적으로 생성되면 정보를 확인합니다.
```sh
$ aws ec2 import-snapshot --description "Red Hat Enterprise Linux 6 Update 8 KVM Guest Image" --disk-container "file://container.json"
```
<br/>
                          
```sh
$ aws ec2 describe-import-snapshot-tasks --import-task-ids import-snap-b32277d46bfc9e23t
```
<br/>

5. EC2 이미지 등록합니다.
```sh
$ aws ec2 register-image --name RHEL6.8-baseos-x86_64 --architecture x86_64 --virtualization-type hvm --ena-support --root-device-name /dev/xvda --block-device-mappings DeviceName=/dev/xvda,Ebs={SnapshotId=snap-05792dbe0b9b13f12}
```
<br/>

## 2. 시작하기
AWS CLI 도구를 활용하여 다음과 예시를 참고하여 클라우드 아키텍처를 생성하고 설정하는 명령어를 실행합니다.<br/>

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

9. `lab1_sg` 이름을 가진 보안 그룹(Security Group)을 생성합니다. 이 보안 그룹은 SSH(Secure Shell)로 접근이 가능해야 합니다.
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

10. 이 보안 그룹은 22포트와 ICMP 통신을 할 수 있어야 합니다.
```sh
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol icmp --port -1 --source-group $SG_ID
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

## 3. 제출 지침
- 학습 포털 프로젝트 페이지에서 인계 탭을 클릭하고 과제 업로드를 클릭하고 zip 파일을 업로드하세요.
<br/><br/>

