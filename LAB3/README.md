# LAB 3 - AWS EKS(Elastic Kubernetes Service)에서 웹 어플리케이션 배포
이 LAB에서는 퍼블릭 인터넷에서 사용자가 소비할 수 있는 두 개의 작업자 노드 클라우드 프로덕션 쿠버네티스 클러스터(EKS)에 컨테이너화된 웹 앱을 배포합니다. 컨테이너의 오케스트레이션은 쿠버네티스 스택을 사용하여 이루어집니다.<br/>
이 저장소는 두 개의 배포 YAML 파일(app-deployment.yaml, mongo-deployment.yaml)과 두 개의 서비스 YAML 파일(app-service.yaml, mongo-service.yaml)로 구성되어 있습니다. 배포 manifests는 nodejs 애플리케이션과 mongoDB 데이터베이스를 다른 포드에 배포하는 역할을 하는 반면, 서비스 manifests는 네트워크를 통해 파드를 노출하고 해당 파드에 액세스하는 방법에 대한 정책과 함께 논리적 엔드포인트 세트를 정의하는 역할을 합니다.
<br/>
<img width="1000" alt="image" src="https://github.com/user-attachments/assets/3a40ca91-b1e1-4d35-a1d1-1f8fc7cbe5d0" />

## 전제 조건
- AWS 계정
- 필요한 권한을 가진 IAM 사용자
- 터미널 접근
- AWS CLI, kubectl 및 Git을 수강생 PC환경에 설치
- Docker, Kubernetes, AWS EKS 및 Git에 대한 기본 지식
<br/><br/>

## 목표 아키텍처
![이미지 2](https://github.com/user-attachments/assets/8328c841-0571-4ea6-8bab-42eeea079906)

<br/><br/>

## 테스트 결과
<br/><br/>


## 저작자
- Kim, Dong Hyun (티스토리) [https://www.linkedin.com/in/kim-donghyun0916/](https://rhlinux.tistory.com)
- Kim, Dong Hyun (Credly) https://www.credly.com/users/kim-donghyun0916
- Kim, Dong Hyun (Lindin) https://www.linkedin.com/in/kim-donghyun0916/
<br/><br/>
