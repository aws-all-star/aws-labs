# 연습 1. CloudWatch를 사용하여 인스턴스 모니터링
Amazon CloudWatch는 AWS 리소스와 애플리케이션의 메트릭, 로그, 이벤트를 수집·분석하는 모니터링 서비스입니다. EC2 인스턴스에 대해 CPU, 디스크 I/O, 네트워크 트래픽 같은 기본 지표를 자동 수집하며, CloudWatch Agent를 설치하면 메모리, 디스크 사용률, 애플리케이션 로그까지 모니터링할 수 있습니다.
알람 기능을 통해 특정 임계값 초과 시 알림을 제공하거나 Auto Scaling과 연동하여 자동 확장/축소도 가능하며, 또한 CloudWatch Logs를 통해 로그를 중앙집중 관리하고, Logs Insights로 검색·분석할 수 있습니다.
대시보드를 활용하면 다양한 메트릭과 알람 현황을 시각화해 실시간 운영 상태를 한눈에 확인할 수 있는 CloudWatch는 AWS 환경에서 성능, 안정성, 비용 최적화를 지원하는 핵심 모니터링 도구입니다.
<br/>
<img width="850" height="405" alt="image" src="https://github.com/user-attachments/assets/d605ce77-0bf6-4bec-9f30-452822c8b452" />

## 1. 준비하기
CloudWatch를 구성하기 위해서는 먼저 모니터링할 리소스와 수집할 지표의 범위를 정의하는 준비가 필요합니다. 일반적으로 EC2 인스턴스를 예로 들면, 기본 제공되는 메트릭만 사용할지, 아니면 메모리 사용량·디스크 사용률 같은 OS 레벨 지표와 애플리케이션 로그까지 포함할지를 먼저 결정해야 합니다. 이를 위해 사전에 IAM 역할과 권한을 준비하는 것이 중요합니다. CloudWatch에 메트릭과 로그를 전송하기 위해서는 EC2 인스턴스 또는 애플리케이션이 CloudWatch에 데이터를 보낼 수 있는 권한을 가져야 하므로, CloudWatchAgentServerPolicy 같은 IAM 정책을 포함한 역할을 생성하고 인스턴스에 연결합니다.
<br/><br/>

**a) 환경 변수 지정 (반드시 본인 환경에 맞게 수정하도록 합니다.)**
```sh
REGION=ap-northeast-2                   # 리전
INSTANCE_ID=<i-xxxxxxxxxx>              # 대상 EC2 인스턴스 ID
ROLE_NAME=EC2CloudWatchAgentRole        # 새로 만들 IAM 역할 이름
PROFILE_NAME=EC2CloudWatchAgentProfile  # 인스턴스 프로파일 이름
PARAM_NAME=/CWAgent/config/ec2/rocky9   # CWAgent 설정을 저장할 SSM 파라미터 경로
DASH_NAME=ec2-observability-$INSTANCE_ID
```
<br/>

**b) EC2가 CloudWatch/SSM에 쓰기 위한 권한을 부여할 수 있도록 IAM 역할 & 인스턴스 프로파일 생성/연결합니다.**
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
<br/>

**c) EC2 인스턴스가 CloudWatch에 접근할 수 있도록 사용할 역할을 생성하도록 설정합니다.**
```sh
aws iam create-role --role-name $ROLE_NAME --assume-role-policy-document file://trust.json
```
<br/>

**d) 앞에서 만든 IAM 역할($ROLE_NAME)에 필요한 권한 정책(Policy) 두 개를 연결(attach)하는 명령어로 EC2 인스턴스가 CloudWatch와 SSM을 사용할 수 있게 IAM 권한을 부여합니다.**
```sh
aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy
aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
```
<br/>

**e) EC2 인스턴스가 사용할 IAM 인스턴스 프로파일(Instance Profile) 을 만들고, 그 안에 앞에서 만든 역할(Role) 을 연결하도록 합니다.**
```sh
aws iam create-instance-profile --instance-profile-name $PROFILE_NAME
aws iam add-role-to-instance-profile --instance-profile-name $PROFILE_NAME --role-name $ROLE_NAME
```
<br/>

**f) EC2 인스턴스에 프로파일 연결합니다.**
```sh
aws ec2 associate-iam-instance-profile --region $REGION --iam-instance-profile Name=$PROFILE_NAME --instance-id $INSTANCE_ID
```
<br/>

## 2. CloudWatch Agent 수집 설정
CloudWatch Agent 수집 설정(메모리/디스크/네트워크 포함) 작성 & SSM 파라미터로 저장합니다. 단, 메모리/디스크 사용률은 기본 EC2 메트릭에 없고, CloudWatch Agent가 필요합니다.
<br/>

**a) 설정 JSON 만들기**
```sh
cat > cwagent-config.json <<'EOF'
{
  "agent": {
    "metrics_collection_interval": 60,
    "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
  },
  "metrics": {
    "append_dimensions": {
      "InstanceId": "${aws:InstanceId}"
    },
    "metrics_collected": {
      "mem": {
        "measurement": ["mem_used_percent","mem_available","swap_used_percent"],
        "metrics_collection_interval": 60
      },
      "disk": {
        "resources": ["*"],
        "measurement": ["disk_used_percent","inodes_free"],
        "drop_device": true,
        "metrics_collection_interval": 60
      },
      "netstat": {
        "measurement": ["tcp_established","tcp_time_wait"],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF
```
<br/>

**b) SSM Parameter Store에 업로드**
```sh
aws ssm put-parameter --region $REGION --name $PARAM_NAME --type String --overwrite --value "$(cat cwagent-config.json)"
```
<br/>


## 3. CloudWatch Agent 설치 & 설정 적용(SSM Run Command 사용)
**a) AWS Systems Manager(SSM) 를 통해 지정한 EC2 인스턴스($INSTANCE_ID)에 CloudWatch Agent를 원격으로 설치합니다.**
```sh
aws ssm send-command \
  --region $REGION \
  --document-name "AWS-ConfigureAWSPackage" \
  --targets "Key=instanceids,Values=$INSTANCE_ID" \
  --parameters '{"action":["Install"],"installationType":["Uninstall and reinstall"],"name":["AmazonCloudWatchAgent"]}' \
  --comment "Install CloudWatch Agent"
```
<br/>

**b) SSM을 이용해 EC2에 저장된 설정 파일로 CloudWatch Agent를 구성하고 실행하도록 합니다.**
```sh
aws ssm send-command \
  --region $REGION \
  --document-name "AmazonCloudWatch-ManageAgent" \
  --targets "Key=instanceids,Values=$INSTANCE_ID" \
  --parameters "{\"action\":[\"configure\"],\"mode\":[\"ec2\"],\"optionalConfigurationSource\":[\"ssm\"],\"optionalConfigurationLocation\":[\"$PARAM_NAME\"],\"optionalRestart\":[\"yes\"]}" \
  --comment "Configure & start CloudWatch Agent"
```
<br/>

## 4. 메트릭 수집 확인 (CLI로 네임스페이스 조회)
**a) CloudWatch에 저장된 EC2 인스턴스($INSTANCE_ID)의 메트릭 목록을 조회하도록 합니다.**
```sh
aws cloudwatch list-metrics --region $REGION --namespace "AWS/EC2" --dimensions Name=InstanceId,Value=$INSTANCE_ID | head
```
<br/>

**b) CloudWatch Agent가 설치되어 수집 중인 메모리, 디스크 사용률, 스왑, TCP 연결 수 등의 지표를 확인할 수 있습니다.**
```sh
aws cloudwatch list-metrics --region $REGION --namespace "CWAgent" --dimensions Name=InstanceId,Value=$INSTANCE_ID | head
```
<br/>

## 5. CloudWatch 대시보드 생성 (CPU/Mem/Disk/Net 위젯)
**a) 대시보드 JSON 작성**
```sh
cat > dashboard.json <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0, "y": 0, "width": 8, "height": 6,
      "properties": {
        "title": "CPUUtilization (Avg & p95)",
        "region": "$REGION",
        "period": 60,
        "yAxis": { "left": { "max": 100 } },
        "metrics": [
          [ "AWS/EC2", "CPUUtilization", "InstanceId", "$INSTANCE_ID", { "stat": "Average" } ],
          [ ".", "CPUUtilization", ".", ".", { "stat": "p95" } ]
        ]
      }
    },
    {
      "type": "metric",
      "x": 8, "y": 0, "width": 8, "height": 6,
      "properties": {
        "title": "Memory Used % (CWAgent)",
        "region": "$REGION",
        "period": 60,
        "yAxis": { "left": { "max": 100 } },
        "metrics": [
          [ "CWAgent", "mem_used_percent", "InstanceId", "$INSTANCE_ID", { "stat": "Average" } ]
        ]
      }
    },
    {
      "type": "metric",
      "x": 16, "y": 0, "width": 8, "height": 6,
      "properties": {
        "title": "Disk Used % (root, CWAgent)",
        "region": "$REGION",
        "period": 60,
        "yAxis": { "left": { "max": 100 } },
        "metrics": [
          [ "CWAgent", "disk_used_percent", "InstanceId", "$INSTANCE_ID", "path", "/", { "stat": "Average" } ]
        ]
      }
    },
    {
      "type": "metric",
      "x": 0, "y": 6, "width": 12, "height": 6,
      "properties": {
        "title": "Network In/Out (AWS/EC2)",
        "region": "$REGION",
        "period": 60,
        "metrics": [
          [ "AWS/EC2", "NetworkIn",  "InstanceId", "$INSTANCE_ID", { "stat": "Sum" } ],
          [ ".",      "NetworkOut", "InstanceId", "$INSTANCE_ID", { "stat": "Sum" } ]
        ]
      }
    },
    {
      "type": "metric",
      "x": 12, "y": 6, "width": 12, "height": 6,
      "properties": {
        "title": "Disk IO Bytes (Read/Write, AWS/EC2)",
        "region": "$REGION",
        "period": 60,
        "metrics": [
          [ "AWS/EC2", "DiskReadBytes",  "InstanceId", "$INSTANCE_ID", { "stat": "Sum" } ],
          [ ".",       "DiskWriteBytes", "InstanceId", "$INSTANCE_ID", { "stat": "Sum" } ]
        ]
      }
    }
  ]
}
EOF
```
<br/>

**b) CloudWatch 대시보드를 생성(또는 업데이트) 하는 명령어입니다. JSON 형식(dashboard.json)으로 정의된 그래프(위젯) 구성 정보를 사용해 $DASH_NAME 이름의 대시보드를 AWS CloudWatch 콘솔에 등록합니다.**
```sh
aws cloudwatch put-dashboard --region $REGION --dashboard-name "$DASH_NAME" --dashboard-body "file://dashboard.json"
```
<br/>

## 6. (선택) 알람 생성 예시 — CPU/메모리/디스크 사용률
**a) CloudWatch 알람이 보낼 SNS 주제(Topic) 를 새로 생성하는 명령어입니다. 여기서 cw-alerts는 주제 이름으로, 나중에 CloudWatch 알람이 이 주제로 알림을 전송합니다.**
```sh
aws sns create-topic --name cw-alerts --region $REGION
TOPIC_ARN=$(aws sns list-topics --region $REGION --query 'Topics[?contains(TopicArn, `cw-alerts`)].TopicArn' --output text)
```
<br/>

**이메일 구독(선택): 받은 메일에서 Confirm 필요**
```sh
$ aws sns subscribe --topic-arn $TOPIC_ARN --protocol email --notification-endpoint <you@example.com> --region $REGION**
```
<br/>

**b) CloudWatch에 CPU 사용률 알람을 생성하는 명령어입니다. 지정한 EC2 인스턴스의 CPU 평균 사용률이 80% 이상으로 5분(60초 × 5회) 동안 유지될 경우 SNS 알림을 전송합니다.**
```sh
aws cloudwatch put-metric-alarm \
  --region $REGION \
  --alarm-name "CPU>=80%-$INSTANCE_ID" \
  --metric-name CPUUtilization --namespace AWS/EC2 \
  --dimensions Name=InstanceId,Value=$INSTANCE_ID \
  --statistic Average --period 60 --evaluation-periods 5 \
  --threshold 80 --comparison-operator GreaterThanOrEqualToThreshold \
  --alarm-actions $TOPIC_ARN
```
<br/>

**c) CloudWatch 알람을 생성하여, 지정한 EC2 인스턴스의 메모리 사용률(mem_used_percent) 이 85% 이상으로 5분(60초 × 5회) 동안 유지되면 알림을 보내도록 합니다.**
```sh
aws cloudwatch put-metric-alarm \
  --region $REGION \
  --alarm-name "Mem>=85%-$INSTANCE_ID" \
  --metric-name mem_used_percent --namespace CWAgent \
  --dimensions Name=InstanceId,Value=$INSTANCE_ID \
  --statistic Average --period 60 --evaluation-periods 5 \
  --threshold 85 --comparison-operator GreaterThanOrEqualToThreshold \
  --alarm-actions $TOPIC_ARN
```
<br/>

**d) 지정된 EC2 인스턴스의 루트 경로(/) 디스크 사용률(disk_used_percent) 이 80% 이상으로 10분간(300초 × 2회) 지속되면 SNS로 알림을 전송합니다.**
```sh
aws cloudwatch put-metric-alarm \
  --region $REGION \
  --alarm-name "DiskUsed>=80%-$INSTANCE_ID" \
  --metric-name disk_used_percent --namespace CWAgent \
  --dimensions Name=InstanceId,Value=$INSTANCE_ID Name=path,Value=/ \
  --statistic Average --period 300 --evaluation-periods 2 \
  --threshold 80 --comparison-operator GreaterThanOrEqualToThreshold \
  --alarm-actions $TOPIC_ARN
```
<br/>


# 연습 목표
- 대시보드/알람은 즉시 생성되지만, 첫 메트릭 전송까지 1~2분 정도 후 그래프에 나타납니다.
- 디스크 경로가 / 외에 /data 등이라면 대시보드/알람의 path 값을 맞게 수정하세요.
- Rocky 9에서 SSM Agent가 없다면(참고용, CLI 아님): sudo dnf install -y amazon-ssm-agent && sudo systemctl enable --now amazon-ssm-agent
<br/><br/>

