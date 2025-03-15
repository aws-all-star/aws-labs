## 준비하기
이 프로젝트는 Bash Script를 사용하여 MongoDB 데이터베이스에 연결된 Nodejs API 마이크로서비스를 배포합니다. 이 API는 사용자가 HTTP 요청을 보내고 JSON 페이로드로 응답을 받을 수 있는 노출된 엔드포인트를 가질 것이다.

이 프로젝트는 메인 스크립트(api_server_db.sh)와 보조 스크립트로 구성되어 있습니다. 메인 스크립트는 AWS CLI를 사용하여 AWS 클라우드 인프라를 배포하는 역할을 합니다. 특히, AWS 아키텍처에는 VPC, 인터넷 게이트웨이, 두 개의 공용 서브넷, 공용 경로 테이블, 공용 EC2 인스턴스, 자동 스케일링 그룹, 애플리케이션 로드 밸런서, 보안 그룹, NAT 게이트웨이, 하나의 개인 서브넷, 개인 경로 테이블 및 개인 EC2 인스턴스가 있습니다.
<br/><br/>
선택한 데이터와 선택한 데이터베이스 서버를 사용하여 간단한 데이터를 저장하는 데이터베이스를 만듭니다. 예를 들어 2024년도 KBL 등록된 투수 선수 중에 그들의 ERA(평균 자책점), G(경기 수) 및 W(승리 수) 등에 대한 데이터가 있는 첨부된 KBL 데이터를 사용할 수 있습니다.
<br/><br/>

옵션 1: 이 저장소를 복제합니다. 이 옵션을 사용하려면 먼저 터미널에 Git을 설치한 다음 저장소를 복제해야 합니다.<br/>
Git을 설치하려면 이 링크로 이동하여 단계를 따르십시오: https://git-scm.com/book/en/v2/Getting-Started-Installing-Git
```sh
$ git clone
```
<br/>
저장소 복제:<br/>
옵션 2: 스크립트를 다운로드하여 로컬 컴퓨터에 저장하십시오. https://github.com/aws-all-star/aws-labs
<br/>

## 시작하기
1. 리전(REGION)은 ap-northeast-2(Seoul) 에 있는 자원만 활용하고 가용 영역(Availability Zones) 은 'ap-northeast-2a' 와 'ap-northeast-2b' 존재하도록 합니다.
```sh
REGION="ap-northeast-2"
SUBNET1_PUBLIC_AZ="ap-northeast-2a"
SUBNET2_PUBLIC_AZ="ap-northeast-2b"
```
<br/>

2. '10.0.0.0/16' CIDR 블록을 가진, VPC를 생성합니다. tag는 `key=Name ,value=vpc_lab2` 설정합니다.
```sh
VPC_ID=$(aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --tag-specification 'ResourceType=vpc,Tags=[{Key=Name,Value=vpc_lab2}, {Key=project,Value=labs}]' \
    --region $REGION \
    --output text \
    --query 'Vpc.VpcId')
```
<br/>

3. 인터넷 게이트웨이를 생성합니다. tag는 `key=Name ,value=igw_lab2` 설정합니다. tag는 `key=Name ,value=igw-lab2` 설정합니다.
```sh
IGW_ID=$(aws ec2 create-internet-gateway \
    --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=igw-lab2}, {Key=project,Value=labs}]' \
    --output text \
    --query 'InternetGateway.InternetGatewayId')
```
<br/>

4. VPC에 인터넷 게이트웨이 연결되어야 합니다.
```sh
aws ec2 attach-internet-gateway \
    --internet-gateway-id $IGW_ID \
    --vpc-id $VPC_ID
```
<br/>

5. `10.0.0.0/24` 서브넷을 가진, `Public Subnet 1` 를 생성합니다. tag는 `key=Name ,value=subnet_lab1` 설정합니다.
```sh
SUBNET1_PUBLIC=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.0.0/24 \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=public_subnet1_lab2}, {Key=project,Value=labs}]' \
    --availability-zone $SUBNET1_PUBLIC_AZ \
    --region $REGION \
    --output text \
    --query 'Subnet.SubnetId')
```
<br/>

6. Public IP가 자동으로 `Public Subnet 1` 에 할당되도록 합니다.
```sh
aws ec2 modify-subnet-attribute --subnet-id $SUBNET1_PUBLIC --map-public-ip-on-launch
```
<br/>

7. 퍼블릭 서브넷 1 에 대한 경로 테이블(route table)을 생성합니다. tag는 `key=Name ,value=public_rt_lab2` 설정합니다.
```sh
RT_PUBLIC=$(aws ec2 create-route-table --vpc-id $VPC_ID --output text --query 'RouteTable.RouteTableId' \
    --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=public_rt_lab2}, {Key=project,Value=labs}]')
```
<br/>

8. 퍼블릿 
```sh
aws ec2 create-route --route-table-id $RT_PUBLIC --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID
```
<br/>

```sh
aws ec2 associate-route-table --subnet-id $SUBNET1_PUBLIC --route-table-id $RT_PUBLIC
```
<br/>

9. `10.0.9.0/24` 서브넷을 가진, `Public Subnet 2` 를 생성합니다. tag는 `key=Name ,value=public_subnet2_lab2` 설정합니다.
```sh
SUBNET2_PUBLIC=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.9.0/24 \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=public_subnet2_lab2}, {Key=project,Value=labs}]' \
    --availability-zone $SUBNET2_PUBLIC_AZ \
    --region $REGION \
    --output text \
    --query 'Subnet.SubnetId')
```
<br/>

10. Public IP가 자동으로 `Public Subnet 2` 에 할당되도록 합니다.
```sh
aws ec2 modify-subnet-attribute --subnet-id $SUBNET2_PUBLIC --map-public-ip-on-launch
```
<br/>

11. 
```sh
aws ec2 associate-route-table --subnet-id $SUBNET2_PUBLIC --route-table-id $RT_PUBLIC
```
<br/>

12. `10.0.10.0/24` 서브넷을 가진, `Private Subnet` 를 생성합니다. tag는 `key=Name ,value=private_subnet_lab2` 설정합니다.
```sh
SUBNET_PRIVATE=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.10.0/24 \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=private_subnet_lab2}, {Key=project,Value=labs}]' \
    --availability-zone $SUBNET1_PUBLIC_AZ \
    --region $REGION \
    --output text \
    --query 'Subnet.SubnetId')
```
<br/>

13. 
```sh
RT_PRIVATE=$(aws ec2 create-route-table --vpc-id $VPC_ID --output text --query 'RouteTable.RouteTableId' \
    --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=private_rt_lab2}, {Key=project,Value=labs}]')
```
<br/>

14.
```sh
aws ec2 associate-route-table --subnet-id $SUBNET_PRIVATE --route-table-id $RT_PRIVATE
```
<br/>

15. `lab2_key` 이름을 가진 key-pair(키 페어)를 생성합니다.
```sh
aws ec2 create-key-pair \
    --key-name lab2_key \
    --key-type rsa \
    --query 'KeyMaterial' \
    --output text \
    > lab2_key.pem
```
<br/>

16.
```sh
SG_ALB_ID=$(aws ec2 create-security-group \
    --group-name lab2_alb_sg \
    --description "Application Load Balancer sg" \
    --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=lab2_alb_sg}, {Key=project,Value=labs}]' \
    --vpc-id $VPC_ID \
    --output text \
    --query 'GroupId')
```
<br/>

17. 
```sh
aws ec2 authorize-security-group-ingress --group-id $SG_ALB_ID --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SG_ALB_ID --protocol tcp --port 443 --cidr 0.0.0.0/0
```
<br/>

18. 
```sh
SG_APP_ID=$(aws ec2 create-security-group \
    --group-name lab2_app_sg \
    --description "Application sg" \
    --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=lab2_app_sg}, {Key=project,Value=labs}]' \
    --vpc-id $VPC_ID \
    --output text \
    --query 'GroupId')
```
<br/>

19.
```sh
aws ec2 authorize-security-group-ingress --group-id $SG_APP_ID --protocol tcp --port 80 --source-group $SG_ALB_ID
aws ec2 authorize-security-group-ingress --group-id $SG_APP_ID --protocol tcp --port 443 --source-group $SG_ALB_ID
aws ec2 authorize-security-group-ingress --group-id $SG_APP_ID --protocol tcp --port 3000 --source-group $SG_ALB_ID
```
<br/>

20.
```sh
EIP_ALLOC_ID=$(aws ec2 allocate-address \
    --query 'AllocationId' --output text)
```
<br/>

21.
```sh
NAT_GW_ID=$(aws ec2 create-nat-gateway \
    --subnet-id $SUBNET1_PUBLIC \
    --allocation-id $EIP_ALLOC_ID \
    --query 'NatGateway.NatGatewayId' \
    --output text)
```
<br/>

22.
```sh
aws ec2 wait nat-gateway-available --nat-gateway-ids $NAT_GW_ID
```
<br/>

23.
```sh
aws ec2 create-route --route-table-id $RT_PRIVATE --destination-cidr-block 0.0.0.0/0 --gateway-id $NAT_GW_ID
```
<br/>

24.
```sh
SG_DB_ID=$(aws ec2 create-security-group \
    --group-name lab2_db_sg \
    --description "Database sg" \
    --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=lab2_db_sg}, {Key=project,Value=labs}]' \
    --vpc-id $VPC_ID \
    --output text \
    --query 'GroupId')
```
<br/>

25.
```sh
aws ec2 authorize-security-group-ingress --group-id $SG_DB_ID --protocol tcp --port 27017 --source-group $SG_APP_ID
```
<br/>

26.
```sh
aws ec2 authorize-security-group-ingress --group-id $SG_APP_ID --protocol tcp --port 27017 --source-group $SG_DB_ID
```
<br/>

27.
```sh
DB_EC2=$(aws ec2 run-instances \
    --image-id ami-0b39b65eacb043ba3 \
    --count 1 \
    --instance-type t2.micro \
    --key-name lab2_key \
    --subnet-id $SUBNET_PRIVATE \
    --private-ip-address 10.0.10.10 \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=db-ec2}, {Key=project,Value=labs}]' \
    --user-data file://lab2-userdata.sh \
    --security-group-ids $SG_DB_ID \
    --output text \
    --query 'Instances[0].InstanceId')
```
<br/>

28.
```sh
TG_ARN=$(aws elbv2 create-target-group --name lab2-target-group \
    --protocol HTTP \
    --port 3000 \
    --vpc-id $VPC_ID \
    --tags "Key=Name,Value=target_group_lab2" "Key=project,Value=labs" \
    --query 'TargetGroups[0].TargetGroupArn' \
    --output text)
```
<br/>

29.
```sh
ALB_ARN=$(aws elbv2 create-load-balancer --name lab2-load-balancer \
    --subnets $SUBNET1_PUBLIC $SUBNET2_PUBLIC \
    --security-groups $SG_ALB_ID \
    --type application \
    --tags "Key=Name,Value=alb_lab2" "Key=project,Value=labs" \
    --query 'LoadBalancers[0].LoadBalancerArn' \
    --output text)
```
<br/>

30. 
```sh
aws elbv2 create-listener --load-balancer-arn $ALB_ARN \
    --protocol HTTP \
    --port 80 \
    --tags "Key=Name,Value=listener_lab2" "Key=project,Value=labs" \
    --default-actions Type=forward,TargetGroupArn=$TG_ARN
```
<br/>

31. 
```sh
LAUNCH_TEMPLATE_ID=$(aws ec2 create-launch-template --launch-template-name lab2-launch-template \
    --launch-template-data "ImageId=ami-0b39b65eacb043ba3,InstanceType=t2.micro,SecurityGroupIds=$SG_APP_ID,KeyName=lab2_key,UserData=$(base64 userdata_app.sh)" \
    --tag-specifications 'ResourceType=launch-template,Tags=[{Key=Name,Value=launchtemp_lab2}, {Key=project,Value=labs}]' \
    --query 'LaunchTemplate.LaunchTemplateId' \
    --output text)
```
<br/>

32.
```sh
aws autoscaling create-auto-scaling-group --auto-scaling-group-name lab2-scaling-group \
    --launch-template "LaunchTemplateId=$LAUNCH_TEMPLATE_ID,Version=1" \
    --min-size 2 \
    --max-size 4 \
    --desired-capacity 2 \
    --target-group-arns $TG_ARN \
    --vpc-zone-identifier $SUBNET1_PUBLIC,$SUBNET2_PUBLIC \
    --tags "Key=Name,Value=asg_lab2" "Key=Project,Value=labs" \
    --default-cooldown 300
```
<br/>

33. 
```sh
aws autoscaling put-scaling-policy --policy-name cpu-scaling-policy \
    --auto-scaling-group-name lab2-scaling-group \
    --policy-type TargetTrackingScaling \
    --target-tracking-configuration "PredefinedMetricSpecification={PredefinedMetricType=ASGAverageCPUUtilization},TargetValue=80"
```
<br/><br/>

## 테스트 결과
"KBL-Pitcher-2024.csv"라는 csv 파일에는 KBL 투수 선수, 평균 자책점, 경기 승리 수에 대한 데이터가 있습니다. 메인 스크립트를 실행한 후 AWS 인프라를 시작한 지역의 콘솔에서 AWS 계정으로 이동하여 EC2 대시보드를 클릭한 다음 로드 밸런서를 클릭합니다. lab_2 로드 밸런서를 선택하고 DNS 이름을 복사한 다음 원하는 경로를 따라 웹 브라우저에 붙여넣습니다.

경로 "/" -> KBL-Pitcher-2024.csv 모든 문서 내용를 반환합니다.<br/>
경로 "/teams" ->는 모든 팀의 목록을 반환합니다.
<br/><br/>

## 제출 지침
- 2024년도 ERA(평균 자책점) 가장 낮은 투수 선수는 누구인가요?
- TOP 20위 중, 가장 승리 수(W) 높은 투수는 누구인가요?
<br/><br/>
