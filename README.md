
# 목차
  0. [시작하기에앞서](#0-시작하기에앞서)
  1. [준비하기](#1-준비하기)
  2. [설치하기](#2-설치하기)
  3. [시작하기](#3-시작하기)
  4. [글쓴이](#4-글쓴이)
<br/><br/>

## 0. 시작하기에앞서
이 LAB 과정에서는 AWS 서비스를 더욱 능숙하게 식별할 수 있도록 기초 지식을 쌓을 수 있도록 실습 환경을 제공하며, 이 과정을 수강하면 비즈니스 요구 사항에 따라 어떤 IT 솔루션을 사용할 것인지에 대해 정보를 기반으로 한 의사 결정을 하고 AWS에서 작업을 시작할 수 있습니다.<br/>
AWS Cloud 교육의 기본적인 내용으로, AWS 사용을 시작하는 방법을 배우는데 관심이 있으신 분 혹은 AWS 서비스 사용에 관심이 있는 시스템 운영 관리자, 솔루션스 아키텍트 및 개발자 등 AWS 사용을 시작하기에 앞서 관심이 있으신 분들이라면 누구든지 수강하실 수 있는 교육입니다.
또한 모든 LAB에서는 실습(Hand-On)기반 설계된 학습 과정을 통해 단순 이론적인 뿐만 아니라, AWS Cloud 전반적인 이해를 빠르게 할 수 있도록 합니다.
<br/>

이 입문 과정에서는 AWS 제품, 서비스 및 일반 솔루션에 대해 배웁니다. 비즈니스 요구 사항을 기반으로 IT 솔루션에 대해 정보에 입각한 의사 결정을 내릴 수 있도록 AWS 서비스를 식별하는 기초 사항을 학습합니다.
<br/><br/>

**이 과정의 수강 대상**
- AWS 뿐만 아니라, Cloud 를 시작하는 방법을 배우는 데 관심이 있는 개인/조직
- 대규모 AWS 인프라를 관리하는 Admin
- 솔루션스 아키텍트 성장하기 위한 엔지니어
- Cloud 인프라 이해가 필요한 DevOps 초급 개발자
<br/>

**전제조건**
- 리눅스 시스템에 대한 실무 지식
- 일반적인 네트워킹 개념에 대한 이해
- 다중 계층 아키텍처에 대한 실무 경험
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

AWS 계정에 액세스하려면 터미널에서 다음 명령을 실행하십시오.
```sh
$ aws configure
AWS Access Key ID [None]: 
AWS Secret Access Key [None]: 
Default region name [None]: 
Default output format [None]:
```
<br/>
AWS Command Line Interface(AWS CLI)는 명령줄 쉘에서 명령을 사용하여 AWS 서비스와 상호 작용할 수 있는 오픈 소스 도구입니다. AWS CLI는 최소한의 구성으로 브라우저 기반 AWS Management Console에서 제공하는 것과 동일한 기능을 구현하는 명령을 터미널 프로그램의 명령 프롬프트에서 실행할 수 있게 해줍니다.  <br/>
AWS CLI 시작하기에서는 AWS CLI의 설치 및 구성 과정을 안내합니다. 이 단계를 거치고 나면 명령줄에서 AWS 서비스로 직접적으로 호출할 수 있게 됩니다.  명령줄에서 다음 명령을 실행하면 바로 다양한 수준의 도움말을 통해 자세한 정보를 얻을 수 있습니다.<br/>

$ `aws help`
<br/>

서비스 운영에 대한 자세한 정보:<br/>
$ `aws [AWS service] help`
<br/>

특정 서비스 운영에 대한 자세한 정보:<br/>
$ `aws [AWS service] [operation] help`
<br/>

본 과정은 다양한 실습환경에 필요한 도구들이 필요합니다. 학습 진행에 필요한 도구를 설치하려면 아래 링크의 단계를 따르십시오. 설치 방법에 대한 자세한 내용은 다음 링크를 방문하십시오.
- Terminal: https://tabby.sh
- AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
- Git: https://git-scm.com/book/en/v2/Getting-Started-Installing-Git
- Kubectl: https://kubernetes.io/docs/tasks/tools/
- Docker: https://docs.docker.com/engine/install/
- Helm: https://helm.sh/docs/intro/install/
- Ansible: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html
- Terraform: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
<br/>

## 2. 설치하기
이 저장소를 복제하여 사용할 수 있습니다. 이 옵션을 사용하려면 먼저 터미널에 Git을 설치한 다음 저장소를 복제해야 합니다.<br/>
Git을 설치하려면 이 링크로 이동하여 단계를 따르십시오. 필요에 따라 강사에 지시를 따라야 합니다.

```sh
git clone https://github.com/aws-all-star/aws-labs.git
```
<br/>

## 3. 시작하기
AWS 서비스를 더욱 능숙하게 식별할 수 있도록 기초 지식을 제공하므로, 이 과정을 수강하면 비즈니스 요구 사항에 따라 어떤 IT 솔루션을 사용할 것인지에 대해 정보를 기반으로 한 의사 결정을 하고 AWS에서 작업을 시작할 수 있습니다.
학습에 진행되는 과정의 모든 실습 환경은 강사에 의해 제공되며 수강생은 핸즈온 실습 위주의 기본 인프라 구축 및 배포을 경험하여 다양한 기술 요소를 직접 경험할 수 있을 것입니다. 
<br/>

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
  • 애플리케이션이 견딜 수 있는 부하를 확인하기 위해 테스트를 설정할 때는 먼저 초당 요청 수(req/s), 응답 시간(초) 또는 동시 사용자 수를 측정할지 결정합니다. <br/>
  • Prometheus, Loki 및 Grafana를 사용하여 클러스터 및 애플리케이션 메트릭 및 로그를 모니터링합니다.
<br/>

### [LAB 6](https://github.com/aws-all-star/aws-labs/tree/main/LAB6) - Ansible 및 Terraform을 활용한 인프라 프로비저닝
  • 인프라 프로비저닝 자동화 도구(IaaS, 서비스형 인프라스트럭처)를 사용하여 AWS 인프라를 배포합니다.<br/>
  • API 및 데이터베이스가 있는 웹 앱 아키텍처를 호스팅하는 EC2 서버(Ansible 사용), API 및 데이터베이스가 있는 웹 앱을 호스팅하는 AWS EKS 클러스터(Terraform 사용)을 활용하여 인프라를 구성합니다.
<br/><br/>


## 4. 글쓴이
- Kim, Dong Hyun (Blog) https://rhlinux.tistory.com
- Kim, Dong Hyun (Credly) https://www.credly.com/users/kim-donghyun0916
- Kim, Dong Hyun (Linkdin) https://www.linkedin.com/in/kim-donghyun0916/
<br/><br/>

