## 연습 1. CloudWatch를 사용하여 인스턴스 모니터링
Amazon CloudWatch는 AWS 리소스와 애플리케이션의 메트릭, 로그, 이벤트를 수집·분석하는 모니터링 서비스입니다. EC2 인스턴스에 대해 CPU, 디스크 I/O, 네트워크 트래픽 같은 기본 지표를 자동 수집하며, CloudWatch Agent를 설치하면 메모리, 디스크 사용률, 애플리케이션 로그까지 모니터링할 수 있습니다.
알람 기능을 통해 특정 임계값 초과 시 알림을 제공하거나 Auto Scaling과 연동하여 자동 확장/축소도 가능하며, 또한 CloudWatch Logs를 통해 로그를 중앙집중 관리하고, Logs Insights로 검색·분석할 수 있습니다.
대시보드를 활용하면 다양한 메트릭과 알람 현황을 시각화해 실시간 운영 상태를 한눈에 확인할 수 있는 CloudWatch는 AWS 환경에서 성능, 안정성, 비용 최적화를 지원하는 핵심 모니터링 도구입니다.
<br/>
<img width="850" height="405" alt="image" src="https://github.com/user-attachments/assets/d605ce77-0bf6-4bec-9f30-452822c8b452" />

# 1. 준비하기
CloudWatch를 구성하기 위해서는 먼저 모니터링할 리소스와 수집할 지표의 범위를 정의하는 준비가 필요합니다. 일반적으로 EC2 인스턴스를 예로 들면, 기본 제공되는 메트릭만 사용할지, 아니면 메모리 사용량·디스크 사용률 같은 OS 레벨 지표와 애플리케이션 로그까지 포함할지를 먼저 결정해야 합니다. 이를 위해 사전에 IAM 역할과 권한을 준비하는 것이 중요합니다. CloudWatch에 메트릭과 로그를 전송하기 위해서는 EC2 인스턴스 또는 애플리케이션이 CloudWatch에 데이터를 보낼 수 있는 권한을 가져야 하므로, CloudWatchAgentServerPolicy 같은 IAM 정책을 포함한 역할을 생성하고 인스턴스에 연결합니다.
<br/>
a) 환경 변수 지정 (반드시 본인 환경에 맞게 수정하도록 합니다.)
```sh
REGION=ap-northeast-2                 # 리전
INSTANCE_ID=<i-xxxxxxxxxx>            # 대상 EC2 인스턴스 ID
ROLE_NAME=EC2CloudWatchAgentRole      # 새로 만들 IAM 역할 이름
PROFILE_NAME=EC2CloudWatchAgentProfile# 인스턴스 프로파일 이름
PARAM_NAME=/CWAgent/config/ec2/rocky9 # CWAgent 설정을 저장할 SSM 파라미터 경로
DASH_NAME=ec2-observability-$INSTANCE_ID
```
<br/>

b) EC2가 CloudWatch/SSM에 쓰기 위한 권한을 부여할 수 있도록 IAM 역할 & 인스턴스 프로파일 생성/연결합니다.
```sh
cat > trust.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {"Effect":"Allow","Principal":{"Service":"ec2.amazonaws.com"},"Action":"sts:AssumeRole"}
  ]
}
EOF
```

c) 역할 생성
```sh
aws iam create-role --role-name $ROLE_NAME --assume-role-policy-document file://trust.json
```
<br/>
d) 권한(관리형 정책) 연결
```sh
aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy
```
```sh
aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
```
