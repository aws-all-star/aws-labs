# 준비하기
AWS EKS 인프라 설정:
- CloudFormation 템플릿을 사용하여 작업자 노드에 대한 VPC 생성(개인 및 공용 서브넷 옵션 선택)
https://docs.aws.amazon.com/eks/latest/userguide/creating-a-vpc.html
<br/>

다음 단계를 위해 AWS 문서를 확인하여 더 자세한 설명을 확인할 수 있습니다:<br/>
https://docs.aws.amazon.com/eks/latest/userguide/getting-started-console.html#eks-launch-workers
<br/>

1. 클러스터 IAM 역할을 생성하고 필요한 Amazon EKS IAM 관리 정책을 첨부합니다.
2. EKS 클러스터 생성:
  - 이름을 지정하고 최신 버전을 선택한 다음 방금 생성한 EKS IAM 역할을 선택합니다.
  - CloudFormation 템플릿으로 생성된 VPC, 서브넷 및 보안 그룹을 선택합니다.
  - 클러스터 엔드포인트 액세스를 공개 및 비공개로 설정
  - 다른 옵션을 기본값으로 남겨두고 클러스터를 만듭니다 (약 15분 소요)
3. Kubectl을 EKS 클러스터와 연결하세요
  - 터미널에서 aws configure를 실행하고(콘솔에서 EKS 클러스터를 생성한 동일한 사용자를 사용), kubectl을 설치하세요(설치 섹션 확인)
  - 그런 다음 클러스터 이름과 올바른 지역으로 다음 명령을 실행하십시오.
  
```sh
$ aws eks update-kubeconfig --name EKS-Lab --region us-east-1
```
  - 마지막으로, kubectl cluster-info를 실행하여 연결이 성공했는지 확인하십시오.
<br/>

오류가 발생하면 여기에서 답을 찾을 수 있습니다.
https://docs.aws.amazon.com/eks/latest/userguide/troubleshooting.html#unauthorized
<br/>

4. 노드 그룹에 대한 EC2 IAM 역할 생성
5. 노드 그룹 생성
  - EKS 클러스터 페이지에서 클러스터를 선택한 다음 Compute를 클릭하고 노드 그룹을 추가합니다.
  - 이름을 지정하고 노드 그룹 IAM 역할을 선택한 다음 다음을 클릭합니다.
  - Amazon Linux 2 AMI, 주문형 용량, t2.micro 크기, 20GiB 디스크 크기를 선택하고 다음을 클릭하십시오.
  - 원격 액세스를 활성화하고, SSH 키 쌍을 선택하고(문제 해결에 유용할 수 있음), 모든 곳에서 SSH 원격 액세스를 허용하세요.
  - 다음을 클릭하고, 검토하고, 생성하세요(몇 분 소요)
<br/>

필요한 도구를 설치하려면 아래 링크의 단계를 따르십시오.
- AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
- Git: https://git-scm.com/book/en/v2/Getting-Started-Installing-Git
- Kubectl: https://kubernetes.io/docs/tasks/tools/
<br/><br/>

## 시작하기

<br/><br/>

## 제출 지침
