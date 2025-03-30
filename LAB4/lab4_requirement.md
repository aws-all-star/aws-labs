# 준비하기
이 LAB에서는 퍼블릭 인터넷에서 사용자가 소비할 수 있는 두 개의 작업자 노드 클라우드 프로덕션 쿠버네티스 클러스터(EKS)에 컨테이너화된 웹 앱을 배포합니다. 컨테이너의 오케스트레이션은 쿠버네티스 스택을 사용하여 이루어집니다.
<br/>
이 저장소는 두 개의 배포 YAML 파일(app-deployment.yaml, mongo-deployment.yaml)과 두 개의 서비스 YAML 파일(app-service.yaml, mongo-service.yaml)로 구성되어 있습니다. 배포 manifests는 nodejs 애플리케이션과 mongoDB 데이터베이스를 다른 포드에 배포하는 역할을 하는 반면, 서비스 manifests는 네트워크를 통해 파드를 노출하고 해당 파드에 액세스하는 방법에 대한 정책과 함께 논리적 엔드포인트 세트를 정의하는 역할을 합니다.

AWS EKS 인프라 설정: CloudFormation 템플릿을 사용하여 작업자 노드에 대한 VPC 생성(개인 및 공용 서브넷 옵션 선택)
https://docs.aws.amazon.com/eks/latest/userguide/creating-a-vpc.html
<br/><br/>

다음 단계를 위해 AWS 문서를 확인하여 더 자세한 설명을 확인할 수 있습니다:<br/>
https://docs.aws.amazon.com/eks/latest/userguide/getting-started-console.html#eks-launch-workers
<br/><br/>

필요한 도구를 설치하려면 아래 링크의 단계를 따르십시오.:<br/>
- Git: https://git-scm.com/book/en/v2/Getting-Started-Installing-Git
- Kubectl: https://kubernetes.io/docs/tasks/tools/
<br/><br/>

# 시작하기

**1단계: Amazon EKS(Elastic Kubermetes Cluster) 생성**<br/>
1. Amazon EKS 요구 사항을 충족하는 퍼블릭 및 프라이빗 서브넷이 있는 Amazon VPC PC를 생성합니다. region-code를 Amazon EKS에서 지원하는 AWS 리전으로 바꿉니다. AWS 리전 목록은 AWS General Reference 가이드의 Amazon EKS endpoints and quotas를 참조하세요. 선택하는 이름으로 my-eks-vpc-stack을 바꿀 수 있습니다.<br/>
```sh
aws cloudformation create-stack \
  --region ap-northeast-2 \
  --stack-name my-eks-vpc-stack \
  --template-url https://s3.us-west-2.amazonaws.com/amazon-eks/cloudformation/2020-10-29/amazon-eks-vpc-private-subnets.yaml
```
<br/>

2. 클러스터 IAM 역할 생성 및 관리 정책 연결
클러스터 IAM 역할을 생성하고 필요한 Amazon EKS IAM 관리형 정책을 연결합니다. Amazon EKS에서 관리하는 Kubernetes 클러스터는 사용자 대신 다른 AWS 서비스를 호출하여 서비스에 사용하는 리소스를 관리합니다.
```sh
aws iam create-role \
  --role-name myAmazonEKSNodeRole \
  --assume-role-policy-document file://"node-role-trust-policy.json"
```
<br/>

3. 필요한 Amazon EKS 관리형 IAM 정책을 역할에 연결합니다.<br/>
```sh
aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy \
  --role-name myAmazonEKSClusterRole
```

4. https://console.aws.amazon.com/eks/home#/clusters 에서 Amazon EKS 콘솔을 엽니다. 콘솔의 오른쪽 상단에 표시된 AWS 리전이 클러스터를 생성하려는 AWS 리전인지 확인합니다. 수강생은 ap-northeast-2 사용해야 합니다.<br/>

5. 클러스터 생성을 선택합니다. 먼저 왼쪽 검색 창에서 클러스터를 선택합니다.<br/>

6. 클러스터 구성 페이지에서 다음을 수행합니다.<br/>
- 사용자 지정 구성(Custom Configuration) 을 선택하고 EKS 자율 모드(EKS Auto Mode) 사용을 비활성화하세요.<br/>
- 클러스터 이름을 입력하세요(예: `my-ktds`). 이름에는 영숫자(대소문자 구분)와 하이픈만 사용할 수 있습니다. 영숫자로 시작해야 하며 100자 이하여야 합니다. 이름은 클러스터를 생성하는 AWS 리전과 AWS 계정 내에서 고유해야 합니다.<br/>
- 클러스터 서비스 역할(Cluster IAM role)에서 myAmazonEKSClusterRole을 선택합니다.<br/>
- 나머지 설정을 기본값으로 두고 다음을 선택합니다.<br/>

7. 네트워킹 지정 페이지에서 다음을 수행합니다.<br/>
- VPC 드롭다운 목록에서 이전 단계에서 생성한 VPC의 ID를 선택합니다. vpc-00x0000x000x0x000 | my-eks-vpc-stack-VPC를 예로 들 수 있습니다.<br/>
- Subnet 드롭다운 목록에서 my-eks-vpc-stack-xxx 시작하는 서브넷을 모두 선택합니다. 그리고 보안그룹도 my-eks-vpc-xxx 시작하는 목록을 선택합니다. 나머지 설정을 기본값으로 두고 다음을 선택합니다.<br/>
- 관찰성(Observability) 구성 페이지에서 다음을 선택합니다.<br/>

8. 추가 기능 선택 페이지에서 다음을 선택합니다.<br/>

9. 추가 기능에 대한 자세한 내용은 Amazon EKS 추가 기능 섹션을 참조하세요.<br/>

10. 선택한 추가 기능 설정 구성 페이지에서 다음을 선택합니다.<br/>

11. 검토 및 생성 페이지에서 생성을 선택합니다. 클러스터 이름 오른쪽에 있는 클러스터 상태는 클러스터 프로비저닝 프로세스가 완료될 때까지 몇 분 동안 생성 중Creating으로 표시됩니다. 상태가 활성이 되면 다음 단계를 진행합니다.<br/>

오류가 발생하면 여기에서 답을 찾을 수 있습니다.<br/>
https://docs.aws.amazon.com/eks/latest/userguide/troubleshooting.html#unauthorized
<br/><br/>

**2단계: 클러스터와 통신하도록 노드 구성**<br/>
<br/>
이 부분에서는 클러스터에 대해 kubeconfig 파일을 생성합니다. 이 파일의 설정을 사용하면 kubectl CLI를 사용하여 클러스터와 통신할 수 있습니다.
진행하기 전에 1단계에서 클러스터 생성이 성공적으로 완료되었는지 확인합니다.
<br/>

1. 클러스터에 대해 kubeconfig 파일을 생성 또는 업데이트합니다. region-code를 클러스터를 생성한 AWS 리전으로 바꿉니다. my-cluster를 해당 클러스터의 이름으로 바꿉니다.
```sh
$ aws eks update-kubeconfig --region ap-northeast-2 --name <my-ktds>
```
기본적으로 config 파일이 ~/.kube에 생성되거나 새 클러스터의 구성이 ~/.kube의 기존 config 파일에 추가됩니다.
  - 마지막으로, kubectl cluster-info를 실행하여 연결이 성공했는지 확인하십시오.
<br/>

2. 구성을 테스트합니다.
```sh
kubectl get svc
```
<br/>

**3단계: 클러스터 노드 구성**<br/>
1. 필요한 Amazon EKS 관리형 IAM 정책을 역할에 연결합니다.
```sh
aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy \
  --role-name myAmazonEKSNodeRole
aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly \
  --role-name myAmazonEKSNodeRole
aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy \
  --role-name myAmazonEKSNodeRole
```

2. https://console.aws.amazon.com/eks/home#/clusters 에서 Amazon EKS 콘솔을 엽니다.<br/>

3. 1단계: Amazon EKS 클러스터 만들기에서 생성한 클러스터의 이름(예: `my-ktds`)을 선택합니다.<br/>

4. my-cluster 페이지에서 다음을 수행합니다.<br/>

5. 컴퓨팅 탭을 선택합니다.<br/>

6. 노드 그룹 추가를 선택합니다.<br/>

7. 노드 그룹 구성 페이지에서 다음을 수행합니다.<br/>
- 이름에 관리형 노드 그룹(예: `my-nodegroup`)의 고유한 이름을 입력합니다. 노드 그룹 이름은 63자를 초과할 수 없습니다. 문자나 숫자로 시작하되, 나머지 문자의 경우 하이픈과 밑줄을 포함할 수 있습니다.<br/>
- 노드 IAM 역할 이름에서 이전 단계에서 생성한 myAmazonEKSNodeRole 역할을 선택합니다. 각 노드 그룹은 고유한 IAM 역할을 사용하는 것이 좋습니다.<br/>
- 다음을 선택합니다.<br/>

8. 컴퓨팅 및 크기 조정 구성 설정 페이지에서 `Amazon Linux 2 AMI`, `주문형 용량`, `t2.small` 크기, `20GiB 디스크 크기`를 원하는 노드 수를 4개로, 최소 크기를 2개로, 최대 크기를 6개로 설정합니다.<br/>

10. 네트워킹 지정 페이지에서 기본값을 수락하고 다음을 선택합니다.<br/>

11. 검토 및 생성 페이지에서 관리형 노드 그룹 구성을 검토하고 생성을 선택합니다.<br/>

12. 몇 분 후 노드 그룹 구성 섹션의 상태가 생성 중에서 활성으로 바뀝니다. 상태가 활성이 되면 다음 단계를 진행합니다.<br/>

13. 아래 제공된 manifests 를 찾을 수 있습니다. 다음 명령을 실행하여 응용 프로그램을 배포합니다.<br/>
```sh
kubectl apply -f mongo-service.yaml
kubectl apply -f mongo-deployment.yaml
kubectl apply -f app-service.yaml
kubectl apply -f app-deployment.yaml
```
<br/><br/>

# 제출 지침
- 터미널에서 kuberctl get svc 명령을 사용하여 로드 밸런서의 외부 IP를 가져오세요.
- kuberctl 명령어를 통해 Kubernetes 상태를 확인할 수 있어야 합니다.
<br/><br/>
