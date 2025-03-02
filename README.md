# 목차
- 1. [준비하기](#getting-started)
- 2. [시작하기](#installation)
- 3. [Usage](#usage)
- 4. [Network Diagram](#network-diagram)
- 5. [저작자](#authors)
<br/><br/>
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

## 2. 시작하기
본 LAB 에서는 AWS 제품, 서비스 및 일반적인 솔루션을 소개합니다. 
AWS 서비스를 더욱 능숙하게 식별할 수 있도록 기초 지식을 제공하므로, 이 과정을 수강하면 비즈니스 요구 사항에 따라 어떤 IT 솔루션을 사용할 것인지에 대해 정보를 기반으로 한 의사 결정을 하고 AWS에서 작업을 시작할 수 있습니다.

이 1일 과정에서는 AWS 기반 클라우드 컴퓨팅, 스토리지 및 네트워킹의 기본 요소에 대해 알아봅니다.
또한, 학습에 진행되는 과정의 모든 실습 환경은 강사에 의해 제공되며 수강생은 핸즈온 실습 위주의 기본 인프라 구축 및 배포을 경험하여 다양한 기술 요소를 직접 경험할 수 있을 것입니다. 


### LAB 1. Bash Shell 스크립팅을 사용한 AWS 인프라 프로비저닝
  • RHEL, Rocky Linux, Ubuntu 등 가상화 이미지(VHDK, QCOW2)를 AWS VM IMPORT기능을 이용하여 AWS 클라우드로 안전하게 전환합니다.
  • AWS CLI 및 Bash 스크립팅을 활용하여 소프트웨어 라이브러리 최신으로 업데이트하고 개발환경에 필요한 필수 Python, Node, Java 를 설치하는 Linux EC2 인스턴스로 AWS 인프라 프로비저닝을 자동화합니다.
  • SSH로 여러 서버에 원격으로 액세스, 구성 및 안전하게 관리합니다.

### LAB 2. AWS의 API 서버 및 데이터베이스 구성

## 4. 저작자

- Kim, Dong hyun - https://www.credly.com/users/kim-donghyun0916
