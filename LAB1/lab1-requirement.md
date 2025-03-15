## 1. 준비하기
VM Import/Export를 사용해 손쉽게 기존 환경의 가상 머신 이미지를 Amazon EC2 인스턴스로 가져오고 다시 온프레미스 환경으로 내보낼 수 있습니다. VM Import/Export를 사용하면 IT 보안, 구성 관리, 규정 준수 요구 사항을 충족하기 위해 구축한 가상 머신을 Amazon EC2로 가져와 인스턴스로 즉시 사용할 수 있어 가상 머신에 대한 기존 투자를 활용할 수 있습니다. 또한 가져온 인스턴스를 다시 온프레미스 가상화 인프라로 다시 내보낼 수 있으므로 IT 인프라 전반에 워크로드를 배포할 수 있습니다.

<img width="700" alt="image" src="https://github.com/user-attachments/assets/16277ed4-50f6-48b5-918c-33845a486c5e" />

이미지를 가져오려면, AWS CLI, 다른 개발자 도구 또는 콘솔 기반 Migration Hub Orchestrator 템플릿을 사용하여 기존 온프레미스 또는 가상화 그리고 이기종 클라우드 환경에서 가상 머신 이미지를 가져옵니다. VMware 또는 Openstack 가상화 플랫폼을 사용하는 경우에는 AWS Management Portal을 통해 VM을 가져올 수도 있습니다. 가져오기 프로세스의 일부로서, VM Import에서 VM을 Amazon EC2 인스턴스를 실행하는 데 사용할 수 있는 Amazon EC2 AMI로 변환합니다. VM을 가져오면, Auto Scaling, Elastic Load Balancing, CloudWatch 등의 서비스를 통한 Amazon의 탄력성, 확장성 및 모니터링 기능을 활용해 가져온 이미지를 지원할 수 있습니다.

수강생은 강사의 지시에 따라 가공된 클라우드 이미지(QCOW2)를 제공받게 됩니다. 제공된 클라우드 이미지를 RAW 이미지로 변환하기 위해서는 아래 예시를 통해 각 클라이언트 환경에 맞게 설치할 수 있어야 합니다.<br/>
아래 사이트 제공되는 툴을 설치하여 기존 가상화 이미지를 AWS Cloud로 전환할 수 있도록 변환해야만 합니다.<br/>
https://www.qemu.org/download/
<br/><br/>
설치가 정상적으로 완료되면 AWS에서 제공되는 VM IMPORT 기능을 통해 전환할 수 있습니다.<br/>
다만, VM Import/Export로 가져오는 리소스에 대한 요구 사항을 사전에 파악하고 지원하는 이미지 형식 또는 운영체제인지를 확인해야 합니다.<br/>
https://docs.aws.amazon.com/ko_kr/vm-import/latest/userguide/prerequisites.html
<br/><br/>

아래 예제를 참고하여 순서대로 s3 생성하고 권한을 부여하여 AWS EC2 인스턴스를 생성할 수 있도록 명령어를 실행해야 합니다.
<br/>

1. 강사에게 제공받은 QCOW2 이미지를 RAW 이미지로 변환합니다.
```sh
$ qemu-img convert rhel-guest-image-6.8-20160425.0.x86_64.qcow2 rhel-guest-image-6.8-20160425.0.x86_64.raw
```
<br/>

2. my-ktds 라는 이름의 AWS S3 버킷 생성한 후, 변환된 RAW이미지를 s3 버킷으로 업로드합니다.
```sh
$ aws s3api create-bucket --bucket my-ktds --region ap-northeast-2 --create-bucket-configuration LocationConstraint=ap-northeast-2
```
<br/>

```sh
$ aws s3 cp rhel-guest-image-6.8-20160425.0.x86_64.raw s3://my-ktds 
```
<br/>

3. AWS S3 권한 부여합니다.trust-policy, role-policy.json, bucket-policy.json 파일은 강사에게 제공받게 됩니다.
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
<br/><br/>

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

인스턴스를 생성하기 전에 `aws ec2 describe-images --owners self` 명령어로 현재 생성되어 있는 AMI(Amazon Machine Image)를 확인하여 선택합니다.
<br/><br/>

12. server1과 station1 이름을 가진 EC2 인스턴스 2개를 생성합니다. 해당 인스턴스는 임의로 가공된 AMI를 사용합니다. AMI는 사용자가 생성한 인스턴스를 의미합니다.
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

13. 아래 명령어를 통해 EC2 인스턴스의 Public IP 를 확인할 수 있고, ssh 명령어로 서버에 접속할 수 있어야 합니다.

```sh
aws ec2 describe-instances \
--query "Reservations[*].Instances[*].{PublicIP:PublicIpAddress,Type:InstanceType,Name:Tags[?Key=='Name']|[0].Value,Status:State.Name}"  \
--filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values='*'"  \
--output table
```
<br/>

```sh
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId, PublicIpAddress]' --output table
```
<br/><br/>

## 3. 제출 지침
- 사용자의 운영체제는 보안취약점에 노출되어 있습니다. 수강생은 Linux 운영체제를 최신 버전으로 업데이트해야 합니다. 최신 버전의 커널은 무엇입니까? (Z-Stream 버전 포함)
- AWS 클라우드 환경에 최적화된 성능을 유지하려면 tuned 명령어를 통해 손쉽게 적용할 수 있습니다. 적용 후, 어떠한 차이점이 있는지 확인해야 합니다.
<br/><br/>
