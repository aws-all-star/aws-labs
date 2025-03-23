# 준비하기
이 LAB에서는 MongoDB 데이터베이스에 연결된 Nodejs API 마이크로서비스를 배포합니다. 이 API는 사용자가 HTTP 요청을 보내고 JSON 페이로드로 응답을 받을 수 있는 노출된 엔드포인트를 가질 것이다.

AWS CLI를 사용하여 AWS 클라우드 인프라를 배포하는 역할을 합니다. 특히, AWS 아키텍처에는 VPC, 인터넷 게이트웨이, 두 개의 공용 서브넷, 공용 경로 테이블, 공용 EC2 인스턴스, 자동 스케일링 그룹, 애플리케이션 로드 밸런서, 보안 그룹, NAT 게이트웨이, 하나의 개인 서브넷, 개인 경로 테이블 및 개인 EC2 인스턴스가 있습니다.
<br/><br/>
선택한 데이터와 선택한 데이터베이스 서버를 사용하여 간단한 데이터를 저장하는 데이터베이스를 만듭니다. 예를 들어 2024년도 KBL 등록된 투수 선수 중에 그들의 ERA(평균 자책점), G(경기 수) 및 W(승리 수) 등에 대한 데이터가 있는 첨부된 KBL 데이터를 사용할 수 있습니다.
<br/><br/>

이 저장소를 복제합니다. 이 옵션을 사용하려면 먼저 터미널에 Git을 설치한 다음 저장소를 복제해야 합니다.<br/>
Git을 설치하려면 이 링크로 이동하여 단계를 따르십시오: https://git-scm.com/book/en/v2/Getting-Started-Installing-Git
```sh
$ git clone https://github.com/aws-all-star/aws-labs.git
```
<br/><br/>

# 시작하기
1. 리전(REGION)은 ap-northeast-2(Seoul) 에 있는 자원만 활용하고 가용 영역(Availability Zones) 은 'ap-northeast-2a' 와 'ap-northeast-2b' 존재하도록 합니다.
```sh
REGION="ap-northeast-2"
SUBNET1_PUBLIC_AZ="ap-northeast-2a"
SUBNET2_PUBLIC_AZ="ap-northeast-2b"
```
<br/>

2. 다음 절차에 따라 Virtual Private Cloud(VPC)를 생성합니다. VPC에서 AWS 리소스를 생성하려면 먼저 VPC에 서브넷, 라우팅 테이블, 게이트웨이와 같은 추가 리소스가 있어야 합니다. '10.0.0.0/16' CIDR 블록을 가진, VPC를 생성합니다. tag는 `key=Name ,value=vpc_lab2` 설정합니다.
```sh
VPC_ID=$(aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --tag-specification 'ResourceType=vpc,Tags=[{Key=Name,Value=vpc_lab2}, {Key=project,Value=labs}]' \
    --region $REGION \
    --output text \
    --query 'Vpc.VpcId')
```
<br/>

3. 인터넷 게이트웨이는 VPC 라우팅 테이블에서 인터넷 라우팅 가능 트래픽에 대한 대상을 제공합니다. IPv4 통신의 경우 인터넷 게이트웨이는 Network Address Translation(NAT)도 수행합니다. 아래 명령어를 참고하여 인터넷 게이트웨이를 생성합니다.
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

5. 지정된 VPC에 서브넷을 생성합니다. IPv4 전용 서브넷의 경우 IPv4 CIDR 블록을 지정합니다. VPC에 IPv6 CIDR 블록이 있는 경우 대신 IPv6 전용 서브넷 또는 듀얼 스택 서브넷을 생성할 수 있습니다. 다음 create-subnet 예제에서는 지정된 IPv4 CIDR 블록을 사용하여 지정된 VPC에서 서브넷을 생성합니다.
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

8. 라우팅 테이블에 모든 IPv4 트래픽(0.0.0.0/0)을 IGW로 보내는 라우팅 경로를 생성합니다.
```sh
aws ec2 create-route --route-table-id $RT_PUBLIC --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID
```
<br/>

9. 지정된 라우팅 테이블을 퍼블릿 서브넷 1 과 연결합니다.
```sh
aws ec2 associate-route-table --subnet-id $SUBNET1_PUBLIC --route-table-id $RT_PUBLIC
```
<br/>

10. `10.0.9.0/24` 서브넷을 가진, `Public Subnet 2` 를 생성합니다. tag는 `key=Name ,value=public_subnet2_lab2` 설정합니다.
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

11. `Public Subnet 2`을 수정하여 이 서브넷으로 시작된 모든 인스턴스에 공용 IPv4 주소가 할당되도록 지정합니다.
```sh
aws ec2 modify-subnet-attribute --subnet-id $SUBNET2_PUBLIC --map-public-ip-on-launch
```
<br/>

12. 지정된 라우팅 테이블을 퍼블릿 서브넷 2 과 연결합니다.
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

13. 지정된 VPC에 대한 라우팅 테이블을 생성합니다
```sh
RT_PRIVATE=$(aws ec2 create-route-table --vpc-id $VPC_ID --output text --query 'RouteTable.RouteTableId' \
    --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=private_rt_lab2}, {Key=project,Value=labs}]')
```
<br/>

14. 지정된 라우팅 테이블을 지정된 서브넷과 연결합니다.
```sh
aws ec2 associate-route-table --subnet-id $SUBNET_PRIVATE --route-table-id $RT_PRIVATE
```
<br/>

15. `lab2_key` 이름을 가진 key-pair(키 페어)를 생성합니다. 키 페어를 생성하려면 aws ec2 create-key-pair 명령과 함께 --query 옵션 및 --output text 옵션을 사용하여 프라이빗 키를 직접 파일에 파이프합니다.
```sh
aws ec2 create-key-pair \
    --key-name lab2_key \
    --key-type rsa \
    --query 'KeyMaterial' \
    --output text \
    > lab2_key.pem
```
<br/>

16. Virtual Private Cloud(VPC)와 관련된 보안 그룹을 생성할 수 있습니다. 지정된 VPC에 대한 `lab2_alb_sg` 이름을 가진 보안 그룹을 생성합니다.
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

17. 기본적으로 방화벽 역할을 하는 Amazon Elastic Compute Cloud(Amazon EC2) 인스턴스에 대한 보안 그룹과 함께, 들어오고 나가는 네트워크 트래픽을 결정하는 규칙을 생성할 수 있습니다. 지정된 VPC에 대한 보안 보안 그룹의 인스턴스에 80 포트와 443 포트 규칙을 추가합니다.
```sh
aws ec2 authorize-security-group-ingress --group-id $SG_ALB_ID --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SG_ALB_ID --protocol tcp --port 443 --cidr 0.0.0.0/0
```
<br/>

18. 지정된 VPC에 대한 `lab2_app_sg` 이름을 가진 보안 그룹을 생성합니다.
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

19. 지정된 VPC에 대한 보안 보안 그룹의 인스턴스에 80 포트와 443, 3000 포트 규칙을 추가합니다.
```sh
aws ec2 authorize-security-group-ingress --group-id $SG_APP_ID --protocol tcp --port 80 --source-group $SG_ALB_ID
aws ec2 authorize-security-group-ingress --group-id $SG_APP_ID --protocol tcp --port 443 --source-group $SG_ALB_ID
aws ec2 authorize-security-group-ingress --group-id $SG_APP_ID --protocol tcp --port 3000 --source-group $SG_ALB_ID
```
<br/>

20. 탄력적 IP 주소를 할당합니다. Amazon EC2는 Amazon 주소 풀에서 주소를 선택하게 됩니다.
```sh
EIP_ALLOC_ID=$(aws ec2 allocate-address \
    --query 'AllocationId' --output text)
```
<br/>

21. NAT 게이트웨이는 NAT(네트워크 주소 변환) 서비스입니다. 지정된 서브넷에 NAT 게이트웨이를 생성합니다. 이 작업은 지정된 서브넷에 서브넷의 IP 주소 범위에서 개인 IP 주소를 가진 네트워크 인터페이스를 만듭니다. 공용 NAT 게이트웨이 또는 개인 NAT 게이트웨이를 생성할 수 있습니다.
```sh
NAT_GW_ID=$(aws ec2 create-nat-gateway \
    --subnet-id $SUBNET1_PUBLIC \
    --allocation-id $EIP_ALLOC_ID \
    --query 'NatGateway.NatGatewayId' \
    --output text)
```
<br/>

22. JMESPath가 NatGateways[]를 쿼리할 때까지 기다립니다. ``describe-nat-gateways``로 폴링할 때 모든 요소에 대해 사용할 수 있는 상태 반환. 성공적인 상태에 도달할 때까지 15초마다 투표할 것입니다. 이것은 40개의 실패한 검사 후에 255의 반환 코드로 종료됩니다.
```sh
aws ec2 wait nat-gateway-available --nat-gateway-ids $NAT_GW_ID
```
<br/>

23. 지정된 라우팅 테이블을 지정된 서브넷과 연결합니다.
```sh
aws ec2 create-route --route-table-id $RT_PRIVATE --destination-cidr-block 0.0.0.0/0 --gateway-id $NAT_GW_ID
```
<br/>

24. 지정된 VPC에 대한 `lab2_db_sg` 이름을 가진 보안 그룹을 생성합니다.
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

25. 지정된 VPC에 대한 `lab2_db_sg` 보안 그룹의 27017 포트 규칙을 추가합니다.
```sh
aws ec2 authorize-security-group-ingress --group-id $SG_DB_ID --protocol tcp --port 27017 --source-group $SG_APP_ID
```
<br/>

26. 지정된 VPC에 대한 `lab2_app_sg` 보안 그룹의 27017 포트 규칙을 추가합니다.
```sh
aws ec2 authorize-security-group-ingress --group-id $SG_APP_ID --protocol tcp --port 27017 --source-group $SG_DB_ID
```
<br/>

인스턴스를 생성하기 전에 `aws ec2 describe-images --owners self` 명령어로 현재 생성되어 있는 AMI(Amazon Machine Image)를 확인하여 선택합니다.
<br/><br/>

17. db-ec2 이름을 가진 EC2 인스턴스를 생성합니다. 해당 인스턴스는 임의로 가공된 AMI를 사용합니다. AMI는 사용자가 생성한 인스턴스를 의미합니다.
```sh
DB_EC2=$(aws ec2 run-instances \
    --image-id <ami-사용자 임의 AMI ID> \
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

28. create-target-group 명령을 사용하여 EC2 인스턴스에 사용한 VPC와 동일한 VPC를 지정해서 대상 그룹을 생성합니다.
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

29. create-load-balancer 명령을 사용하여 dualstack 로드 밸런서를 생성합니다. 
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

30. create-listener 명령을 사용하여 요청을 대상 그룹에 전달하는 기본 규칙을 적용해서 로드 밸런서에 대한 리스너를 생성합니다. 
```sh
aws elbv2 create-listener --load-balancer-arn $ALB_ARN \
    --protocol HTTP \
    --port 80 \
    --tags "Key=Name,Value=listener_lab2" "Key=project,Value=labs" \
    --default-actions Type=forward,TargetGroupArn=$TG_ARN
```
<br/>

31. Launch Template은 EC2 인스턴스를 생성할 때 각 단계를 일일이 지정할 필요가 없도록 각 파라미터를 저장할 수 있고 재활용하여 EC2 인스턴스 생성을 간단히 해줍니다.
```sh
LAUNCH_TEMPLATE_ID=$(aws ec2 create-launch-template --launch-template-name lab2-launch-template \
    --launch-template-data "ImageId=ami-0b39b65eacb043ba3,InstanceType=t2.micro,SecurityGroupIds=$SG_APP_ID,KeyName=lab2_key,UserData=$(base64 userdata_app.sh)" \
    --tag-specifications 'ResourceType=launch-template,Tags=[{Key=Name,Value=launchtemp_lab2}, {Key=project,Value=labs}]' \
    --query 'LaunchTemplate.LaunchTemplateId' \
    --output text)
```
<br/>

32. 자동 확장 그룹을 생성할 때 Amazon EC2 인스턴스, 인스턴스에 대한 가용성 영역 및 VPC 서브넷, 원하는 용량, 최소 및 최대 용량 제한을 구성하는 데 필요한 정보를 지정해야 합니다.
자동 스케일링 그룹에 의해 실행되는 Amazon EC2 인스턴스를 구성하려면 실행 템플릿 또는 실행 구성을 지정할 수 있습니다. 다음 절차에서는 실행 템플릿을 사용하여 자동 확장 그룹을 생성하는 방법을 안내합니다.
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

33. 자동 스케일링 그룹에 대한 스케일링 정책을 생성하거나 업데이트합니다. 확장 정책은 구성 가능한 메트릭을 기반으로 자동 확장 그룹을 확장하는 데 사용됩니다. 정책이 정의되지 않으면 동적 스케일링 및 예측 스케일링 기능이 사용되지 않습니다.
```sh
aws autoscaling put-scaling-policy --policy-name cpu-scaling-policy \
    --auto-scaling-group-name lab2-scaling-group \
    --policy-type TargetTrackingScaling \
    --target-tracking-configuration "PredefinedMetricSpecification={PredefinedMetricType=ASGAverageCPUUtilization},TargetValue=80"
```
<br/><br/>


# 제출 지침
- 2024년도 ERA(평균 자책점) 가장 낮은 투수 선수는 누구인가요?
- TOP 20위 중, 가장 승리 수(W) 높은 투수는 누구인가요?
<br/><br/>
