# LAB 1. AWS 인프라 기본 구성 및 최적화
이 LAB 에서 AWS CLI 명령줄 도구와 Bash Shell 스크립트를 사용하여 AWS 클라우드 인프라를 배포합니다. AWS 클라우드 환경에는 VPC, 인터넷 게이트웨이, 공용 서브넷, 공용 경로 테이블 및 세 개의 EC2 인스턴스가 있습니다. 
EC2 인스턴스는 동일한 공용 서브넷과 VPC에 있어야 하며, 서로 연결할 수 있어야 하며, SSH로 원격으로 액세스할 수 있어야 합니다. 또한 인스턴스에는 Python 3.10, Node 18.0, Java 11.0 및 Docker 엔진이 설치되어 있어야 합니다.
<br/><br/>

## 1. 요구사항
1. AWS CLI 도구를 활용하여 다음과 같은 클라우드 아키텍처를 생성하고 설정하는 bash 셸 스크립트를 만듭니다.
   1. ap-northeast-1에 있는 자원만 활용한다.
   2. VPC
   3. Internet gateway
      1. VPC에 인터넷 게이트웨이 연결되어야 한다.
   4. Public subnet
   5. Public subnet 에서 Public IP 자동 할당하도록 되어야 한다.
   6. Pubilc subnet 에 대한 Public 경로 테이블(Route Table)
      1. 경로 테이블(Route Table)에는 인터넷 게이트웨이에 대한 라우팅 규칙이 있다.
   7. Public subnet을 Public 경로 테이블(route table)과 연결해야 한다.
   8. EC2 인스턴스
      1. Master node 1
         1. 크기 : t2.small
         2. 이미지 : Rocky Linux 9.5
         3. 설치 소프트웨어
            1. Python 3.10
            2. Node 18.0
            3. Java 11.0
            4. Docker engine
         4. 태그 `key=Name ,value=master-node-01`
      2. Worker node 1
         1. 크기 : t2.micro
         2. 이미지 : Rocky Linux 9.5
         3. 설치 소프트웨어
            1. Python 3.10
            2. Node 18.0
            3. Java 11.0
            4. Docker engine
         4. Tag `key=Name ,value=worker-node-01`
      3. Worker node 2
         1. 크기 : t2.micro
         2. 이미지 : Rocky Linux 9.5
         3. 설치 소프트웨어
            1. Python 3.10
            2. Node 18.0
            3. Java 11.0
            4. Docker engine
         4. Tag `key=Name ,value=worker-node-02`
   9. 3개의 모든 인스턴스는,
      1. 모든 Linux 서버는 최신 버전의 커널과 라이브러리를 유지해야 한다.
      2. 동일한 Public 서브넷과 VPC에서,
      3. 서로 간 통신할 수 있습니다. - 예를 들어 ping 명령을 통해
      4. SSH로 원격으로 접근할 수 있고,
      5. 생성된 모든 리소스는 태그가 지정되어야 합니다.: `key=labs ,value=awscloud`
<br/><br/>

## 2. 네트워크 다이어그램
<img width="721" alt="image" src="https://github.com/user-attachments/assets/704d2fb5-179f-48e4-9865-94b08e246a24" />
<br/><br/>

## 3. 제출 지침
- 완성된 GitHub 저장소의 zip을 다운로드하세요.
- 학습 포털 프로젝트 페이지에서 인계 탭을 클릭하고 과제 업로드를 클릭하고 zip 파일을 업로드하세요.

<br/><br/>
