# LAB 4 - AWS EKS(Elastic Kubernetes Service)에서 웹 어플리케이션 배포
**Amazon EKS 기능 개요**<br/>
Amazon Elastic Kubernetes Service(Amazon EKS)는 AWS와 온프레미스에서 손쉽게 Kubernetes를 실행할 수 있는 관리형 Kubernetes 서비스입니다. Kubernetes는 컨테이너식 애플리케이션의 배포, 확장 및 관리를 자동화하기 위한 오픈 소스 시스템입니다. Amazon EKS는 Kubernetes 인증 서비스이므로 업스트림 Kubernetes에서 실행되는 기존 애플리케이션과 호환됩니다.
Amazon EKS는 컨테이너 예약, 애플리케이션 가용성 관리, 클러스터 데이터 저장 및 다른 주요 태스크를 담당하는 Kubernetes 제어 영역의 가용성과 확장성을 관리합니다.

Amazon EKS를 사용하면 Amazon Elastic Compute Cloud(Amazon EC2)와 AWS Fargate 모두에서 Kubernetes 애플리케이션을 실행할 수 있습니다. Amazon EKS를 사용하면 AWS 인프라의 모든 성능, 규모, 안정성 및 가용성뿐만 아니라 AWS 네트워킹 및 보안 서비스(로드 분산을 위한 Application Load Balancer(ALB), AWS Identity and Access Management(IAM)와 역할 기반 액세스 제어(RBAC) 통합, Pod 네트워킹을 위한 AWS Virtual Private Cloud(VPC) 지원 등)와의 통합에 따른 이점을 활용할 수 있습니다.

**완전 관리형 Kubernetes**<br/>
Amazon EKS는 여러 AWS 가용 영역(AZ)에 걸쳐 확장 가능하고 가용성이 높은 Kubernetes 컨트롤 플레인을 실행합니다. Amazon EKS는 Kubernetes API 서버 및 etcd 지속성 계층의 가용성과 확장성을 자동으로 관리합니다. Amazon EKS는 여러 AZ에서 Kubernetes 컨트롤 플레인을 실행하여 고가용성을 보장하고 비정상 컨트롤 플레인 노드를 자동으로 감지하고 교체합니다.
Amazon EKS Auto Mode는 AWS의 컴퓨팅, 스토리지, 네트워킹에 대한 Kubernetes 클러스터 인프라 관리를 완전히 자동화합니다. 인프라를 자동으로 프로비저닝하고, 최적의 컴퓨팅 인스턴스를 선택하고, 리소스를 동적으로 확장하고, 비용을 지속적으로 최적화하고, 운영 체제를 패치하고, AWS 보안 서비스와 통합하여 Kubernetes 관리를 간소화합니다.

**Kubernetes 호환성 및 지원**<br/>
Amazon EKS는 업스트림 Kubernetes를 실행하며 Kubernetes 적합성 인증을 받았습니다. 따라서 Kubernetes 커뮤니티의 모든 기존 플러그인과 도구를 사용할 수 있습니다. 온프레미스 데이터 센터에서 실행 중이든 퍼블릭 클라우드에서 실행 중이든 Amazon EKS에서 실행 중인 애플리케이션은 표준 Kubernetes 환경에서 실행 중인 애플리케이션과 완벽하게 호환됩니다. 즉, 코드를 리팩터링하지 않고 표준 Kubernetes 애플리케이션을 Amazon EKS로 쉽게 마이그레이션할 수 있습니다. Amazon EKS는 Amazon EKS에서 릴리스된 시점으로부터 14개월 동안 Kubernetes 마이너 버전에 대한 표준 지원과 추가 12개월 동안 Kubernetes 마이너 버전에 대한 추가 지원(버전당 총 26개월)을 통해 업스트림에서 지원되는 것보다 긴 Kubernetes 버전을 지원합니다. 자세한 정보는 EKS의 Kubernetes 버전 수명 주기 이해을 참조하세요.
<br/>
<img width="1000" alt="image" src="https://github.com/user-attachments/assets/3a40ca91-b1e1-4d35-a1d1-1f8fc7cbe5d0" />

## 전제 조건
- Docker, Kubernetes 네이티브 기술 이해
- Git에 대한 기본 지식
- AWS EKS에 대한 이해
<br/><br/>

## 목표 아키텍처
![이미지 2](https://github.com/user-attachments/assets/8328c841-0571-4ea6-8bab-42eeea079906)

<br/><br/>

## 테스트 결과
터미널에서 다음 명령을 사용하여 로드 밸런서의 외부 IP를 가져오도록 합니다.
```sh
kubectl get services
```

브라우저에 로드 밸런서 외부 IP(로드 밸런서 주소)를 붙여넣고 아래 원하는 경로를 추가하십시오.

1. 경로 "/" 선택하면, KBL-Pitcher-2024 문서를 모든 내용을 출력합니다.</br>
2. 경로 "/teams" 선택하면, 모든 팀의 목록을 출력합니다.
3. 경로 "/players/top/10" 선택하면, ERA(평균 자책점) 가장 낮은 순서의 10명 선수를 출력합니다.
</br></br>

## 저작자
- Kim, Dong Hyun (Blog) https://rhlinux.tistory.com
- Kim, Dong Hyun (Credly) https://www.credly.com/users/kim-donghyun0916
- Kim, Dong Hyun (Lindin) https://www.linkedin.com/in/kim-donghyun0916/
<br/><br/>
