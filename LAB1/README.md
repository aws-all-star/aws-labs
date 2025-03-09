



9. EC2 인스턴스
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
   10. 3개의 모든 인스턴스는,
      1. 모든 Linux 서버는 최신 버전의 커널과 라이브러리를 유지해야 한다.
      2. 동일한 Public 서브넷과 VPC에서,
      3. 서로 간 통신할 수 있습니다. - 예를 들어 ping 명령을 통해
      4. SSH로 원격으로 접근할 수 있고,
      5. 생성된 모든 리소스는 태그가 지정되어야 합니다.: `key=labs ,value=awscloud`
