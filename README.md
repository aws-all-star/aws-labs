# 목차
- 1. [준비하기](#getting-started)
- 2. [시작하기](#installation)
- 3. [Usage](#usage)
- 4. [Network Diagram](#network-diagram)
- 5. [Authors](#authors)
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



## 4. 저작자

- Kim, Dong hyun - 
