## 준비하기
이 LAB 에서 AWS CLI 명령줄 도구와 Bash Shell 스크립트를 사용하여 AWS 클라우드 인프라를 배포합니다. AWS 클라우드 환경에는 VPC, 인터넷 게이트웨이, 공용 서브넷, 공용 경로 테이블 및 세 개의 EC2 인스턴스가 있습니다. 
EC2 인스턴스는 동일한 공용 서브넷과 VPC에 있어야 하며, 서로 연결할 수 있어야 하며, SSH로 원격으로 액세스할 수 있어야 합니다. 또한 인스턴스에는 Python 3.10, Node 18.0, Java 11.0 및 Docker 엔진이 설치되어 있어야 합니다.
<br/><br/>

## 시작하기
1. 선택한 데이터와 선택한 데이터베이스 서버를 사용하여 간단한 데이터를 저장하는 데이터베이스를 만듭니다.
   예를 들어 2024년도 KBL 등록된 투수 선수 중에 그들의 ERA(평균 자책점), G(경기 수) 및 W(승리 수) 등에 대한 데이터가 있는 첨부된 KBL 데이터를 사용할 수 있습니다.
   https://www.koreabaseball.com/Record/Player/PitcherBasic/Basic1.aspx
   
```sh
REGION="ap-northeast-2"
SUBNET1_PUBLIC_AZ="ap-northeast-2a"
SUBNET2_PUBLIC_AZ="ap-northeast-2b"
```
<br/>

```sh
VPC_ID=$(aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --tag-specification 'ResourceType=vpc,Tags=[{Key=Name,Value=vpc_lab2}, {Key=project,Value=labs}]' \
    --region $REGION \
    --output text \
    --query 'Vpc.VpcId')
```
<br/>

```sh
IGW_ID=$(aws ec2 create-internet-gateway \
    --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=igw-lab2}, {Key=project,Value=labs}]' \
    --output text \
    --query 'InternetGateway.InternetGatewayId')
```
<br/>

```sh
aws ec2 attach-internet-gateway \
    --internet-gateway-id $IGW_ID \
    --vpc-id $VPC_ID
```
<br/>

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

```sh
aws ec2 modify-subnet-attribute --subnet-id $SUBNET1_PUBLIC --map-public-ip-on-launch
```
<br/>

```sh
RT_PUBLIC=$(aws ec2 create-route-table --vpc-id $VPC_ID --output text --query 'RouteTable.RouteTableId' \
    --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=public_rt_lab2}, {Key=project,Value=labs}]')
```
<br/>

```sh
aws ec2 create-route --route-table-id $RT_PUBLIC --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID
```
<br/>

```sh
aws ec2 associate-route-table --subnet-id $SUBNET1_PUBLIC --route-table-id $RT_PUBLIC
```
<br/>

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



## 테스트 결과
"KBL-Pitcher-2024.csv"라는 csv 파일에는 KBL 투수 선수, 평균 자책점, 경기 승리 수에 대한 데이터가 있습니다. 메인 스크립트를 실행한 후 AWS 인프라를 시작한 지역의 콘솔에서 AWS 계정으로 이동하여 EC2 대시보드를 클릭한 다음 로드 밸런서를 클릭합니다. lab_2 로드 밸런서를 선택하고 DNS 이름을 복사한 다음 원하는 경로를 따라 웹 브라우저에 붙여넣습니다.

경로 "/" -> KBL-Pitcher-2024.csv 모든 문서 내용를 반환합니다.<br/>
경로 "/teams" ->는 모든 팀의 목록을 반환합니다.

## 목표 구성도

<br/><br/>
