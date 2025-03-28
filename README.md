
# 목차
  0. [시작에앞서](#시작에앞서)
  1. [준비하기](#getting-started)
  2. [설치하기](#installation)
  3. [시작하기](#usage)
  4. [저작자](#authors)
<br/><br/>

## 0. 시작에 앞서
이 AWS LAB 과정에서는 AWS 서비스를 더욱 능숙하게 식별할 수 있도록 기초 지식을 제공하므로, 이 과정을 수강하면 비즈니스 요구 사항에 따라 어떤 IT 솔루션을 사용할 것인지에 대해 정보를 기반으로 한 의사 결정을 하고 AWS에서 작업을 시작할 수 있습니다.<br/>
AWS Cloud 교육의 가장 기초적인 내용으로, AWS 사용을 시작하는 방법을 배우는데 관심이 있으신 분 혹은 AWS 서비스 사용에 관심이 있는 시스템 운영 관리자, 솔루션스 아키텍트 및 개발자 등 AWS 사용을 시작하기에 앞서 관심이 있으신 분들이라면 누구든지 수강하실 수 있는 교육입니다.
또한 모든 LAB에서는 실습(Hand-On)기반 설계된 학습 과정을 통해 단순 이론적인 뿐만 아니라, AWS Cloud 전반적인 이해를 빠르게 할 수 있도록 합니다.
<br/>

이 입문 과정에서는 AWS 제품, 서비스 및 일반 솔루션에 대해 배웁니다. 비즈니스 요구 사항을 기반으로 IT 솔루션에 대해 정보에 입각한 의사 결정을 내릴 수 있도록 AWS 서비스를 식별하는 기초 사항을 학습합니다.
<br/><br/>

**이 과정의 수강 대상**
- AWS 뿐만 아니라, Cloud 를 시작하는 방법을 배우는 데 관심이 있는 개인
- AWS 인프라 관리자 또는 담당자
- 솔루션스 아키텍트
- Cloud 인프라 이해가 필요한 DevOps 개발자
<br/>

**전제조건**
- 분산 시스템에 대한 실무 지식
- 일반적인 네트워킹 개념에 대한 지식
- 다중 계층 아키텍처에 대한 실무 지식
- 클라우드 컴퓨팅 개념 이해
<br/>

## 1. 준비하기
시작에 앞서 AWS 계정(Account), 올바른 권한을 가진 IAM(Identity and Access Management) 사용자, 비밀 액세스 키(key pair)가 필요합니다(비밀 액세스 키로 파일을 다운로드하세요, 나중에 필요합니다). 
아래 예제는 'AdministratorAcess' 정책이 적용된 사용자를 사용했습니다. IAM 사용자 및 비밀 액세스 키에 대한 자세한 내용은 아래 사이트로 이동하십시오.:

https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html
https://docs.aws.amazon.com/powershell/latest/userguide/pstools-appendix-sign-up.html

AWS 콘솔에서 사용자가 생성되면 컴퓨터에서 새 Linux 터미널을 열고 AWS CLI를 설치합니다. 
AWS CLI를 설치하려면 다음 명령을 사용하십시오.
```sh
$ curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
$ unzip awscliv2.zip
$ sudo ./aws/install
```

설치가 정상적으로 완료되었다면 아래 명령어로 설치된 버전을 확인할 수 있습니다.

```sh
aws --version
```

AWS CLI 설치 방법에 대한 자세한 내용은 다음 링크를 방문하십시오.

https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

AWS 계정에 액세스하려면 터미널에서 다음 명령을 실행하십시오.
```sh
$ aws configure
AWS Access Key ID [None]: 
AWS Secret Access Key [None]: 
Default region name [None]: 
Default output format [None]:
```
<br/>

## 2. 설치하기
이 저장소를 복제합니다. 이 옵션을 사용하려면 먼저 터미널에 Git을 설치한 다음 저장소를 복제해야 합니다.<br/>
Git을 설치하려면 이 링크로 이동하여 단계를 따르십시오: https://git-scm.com/book/en/v2/Getting-Started-Installing-Git

```sh
git clone https://github.com/aws-all-star/aws-labs.git
```
<br/><br/>


## 3. 시작하기
AWS 서비스를 더욱 능숙하게 식별할 수 있도록 기초 지식을 제공하므로, 이 과정을 수강하면 비즈니스 요구 사항에 따라 어떤 IT 솔루션을 사용할 것인지에 대해 정보를 기반으로 한 의사 결정을 하고 AWS에서 작업을 시작할 수 있습니다.
학습에 진행되는 과정의 모든 실습 환경은 강사에 의해 제공되며 수강생은 핸즈온 실습 위주의 기본 인프라 구축 및 배포을 경험하여 다양한 기술 요소를 직접 경험할 수 있을 것입니다. 

### [LAB 1](https://github.com/aws-all-star/aws-labs/tree/main/LAB1) - AWS Cloud 기반 Linux 서버 구축
  • 특정 가상화 이미지(VHDK, QCOW2)를 AWS VM IMPORT기능을 이용하여 AWS 클라우드로 안전하게 전환합니다.<br/>
  • AWS CLI 명령어를 활용하여 소프트웨어 라이브러리 최신으로 업데이트하고 최적의 Linux EC2 인스턴스로 AWS 인프라 프로비저닝을 자동화합니다.<br/>
  • SSH로 여러 서버에 원격으로 액세스, 구성 및 안전하게 관리합니다.
<br/>
### [LAB 2](https://github.com/aws-all-star/aws-labs/tree/main/LAB2) - AWS API 서버 및 데이터베이스 구성
  • MongoDB 데이터베이스에 연결된 NodeJS API 마이크로서비스를 배포하여 HTTP 요청에 사용할 수 있는 API 엔드포인트를 노출합니다.<br/>
  • AWS 아키텍처에는 VPC, 인터넷 게이트웨이, 두 개의 공용 서브넷, 경로 테이블, 공용 EC2 인스턴스, 스케일링 그룹, 애플리케이션 로드 밸런서, 보안 그룹, NAT 게이트웨이 등 구성되어야 합니다.
<br/>
### [LAB 3](https://github.com/aws-all-star/aws-labs/tree/main/LAB3) - 애플리케이션 컨테이너화 및 Docker-Compose 구성
  • Docker를 사용하여 API 및 MongoDB 마이크로서비스를 컨테이너화합니다. <br/>
  • 앱 컨테이너를 EC2 인스턴스에 배포하고 Docker Compose로 오케스트레이션합니다.
<br/>
### [LAB 4](https://github.com/aws-all-star/aws-labs/tree/main/LAB4) - AWS EKS 클러스터에서 웹 어플리케이션 배포
  • 컨테이너화된 웹 애플리케이션을 클라우드 프로덕션 쿠버네티스(EKS) 클러스터에 배포합니다.<br/>
  • 클러스터는 공용 인터넷에서 사용자가 소비할 수 있었고, 컨테이너의 오케스트레이션은 쿠버네티스 스택을 사용하여 이루어졌다.
<br/>
### [LAB 5](https://github.com/aws-all-star/aws-labs/tree/main/LAB5) - 옵저버빌리티 시스템 환경 구축
  • 컨테이너화된 웹 애플리케이션을 클라우드 프로덕션 쿠버네티스(EKS) 클러스터에 배포합니다. <br/>
  • Prometheus, Loki 및 Grafana를 사용하여 클러스터 및 애플리케이션 메트릭 및 로그를 모니터링합니다.
<br/><br/>

## 4. 저작자
- Kim, Dong Hyun (티스토리) [https://www.linkedin.com/in/kim-donghyun0916/](https://rhlinux.tistory.com)
- Kim, Dong Hyun (Credly) https://www.credly.com/users/kim-donghyun0916
- Kim, Dong Hyun (Lindin) https://www.linkedin.com/in/kim-donghyun0916/
<br/><br/>

