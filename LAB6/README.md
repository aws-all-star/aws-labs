# LAB 6 - Ansible 및 Terraform을 활용한 인프라 프로비저닝
Ansible 과 HashiCorp Terraform은 모두 IT 환경을 자동화하기 위한 Infrastructure as Code(IaC) 접근 방식을 수용하는 오픈 소스 기반 자동화(Automation) 솔루션입니다.
문제를 해결하는 한 가지 방법만 있는 것이 아닌 것처럼 자동화하는 "올바른" 방법이나 사용할 자동화 도구가 없기 때문에 조직을 위해 이러한 솔루션을 평가하는 것은 단순한 비교가 아닙니다. 기업의 비즈니스 요구 사항은 동일한 업계의 다른 조직의 요구 사항과 완전히 다를 수 있습니다.
<br/>

Terraform과 Ansible Automation Platform은 모두 인기 있는 자동화 제품이자 DevOps 툴이지만, 기능은 매우 다릅니다. Terraform은 IT 자동화 분야의 많은 활용 사례 중 하나인 퍼블릭 클라우드 인프라 프로비저닝을 전문으로 하며, Ansible Automation Platform은 광범위한 자동화 활용 사례를 해결합니다. Ansible Automation Platform은 자동화에 대한 단일 접근 방식 대신 다양한 문제를 해결할 수 있는 다양한 접근 방식을 제공합니다. 고객이 두 가지 자동화 솔루션을 결합하여 가장 잘 해결할 수 있는 특정 문제가 발생하는 경우, Ansible Automation Platform은 Helm 및 Terraform과 마찬가지로 Amazon Web Services(AWS) CloudFormation, Microsoft Azure Resource Manager, Google Cloud Platform(GCP) Cloud Deployment Manager를 비롯한 주요 클라우드 공급업체의 다른 제품과 통합할 수 있습니다.
Ansible과 Terraform은 모두 특정 정책에 따라 여러 자동화 워크플로우를 순서대로 호출할 수 있으므로 오케스트레이터 역할을 할 수 있습니다. Ansible에는 다른 자동화 툴(Terraform 포함)에 연결하고 이를 관리하는 모듈이 내장되어 있습니다. 
결과적으로 Ansible을 모든 팀의 최상위 공통 언어로 사용하여 전체 IT 자산에 걸쳐 자동화 방식을 표준화할 수 있습니다.
![이미지 2](https://github.com/user-attachments/assets/4a68d73c-85ea-4f8f-8c32-b522a6a48afc)

## 전제조건
- Ansible, Terraform 기본 지식
- AWS EKS 및 Git에 대한 이해
- 수강생 개인 Linux서버에 AWS CLI, git, python3, pip, botocore, boto3, ansible 및 Terraform CLI가 설치 필요
<br/><br/>

## 목표 구성도
![이미지 1](https://github.com/user-attachments/assets/3343c0f3-a1f8-4faa-9597-b8a62e933c7e)
<br/><br/>

## 테스트 결과
- PART 1: 생성된 로드 밸런서의 DNS를 복사하고 웹 브라우저에 붙여넣고 원하는 출력에 따라 경로를 편집합니다.
- PART 2: Jenkins EC2 인스턴스의 Public IP를 복사하여 8080포트로 웹 브라우저에 붙여넣습니다.
- PART 3: kubectl get services 명령을 사용하여 로드 밸런서의 External IP를 확인합니다.
1. 경로 "/" 선택하면, KBL-Pitcher-2024 문서를 모든 내용을 출력합니다.</br>
2. 경로 "/teams" 선택하면, 모든 국내 야구 구단의 목록을 출력합니다.
3. 경로 "/players/top/10" 선택하면, ERA(평균 자책점) 가장 낮은 10명에 선수를 출력합니다.
<br/><br/>

## 저작자
- Kim, Dong Hyun (Blog) https://rhlinux.tistory.com
- Kim, Dong Hyun (Credly) https://www.credly.com/users/kim-donghyun0916
- Kim, Dong Hyun (Lindin) https://www.linkedin.com/in/kim-donghyun0916/
<br/><br/>
