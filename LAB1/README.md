

## 2. 목표 구성도
<img width="900" alt="image" src="https://github.com/user-attachments/assets/a442b5e7-329a-476c-b7a9-a984118ccbb8" />
<br/><br/>

## 3. 
1. 모든 Linux 서버는 최신 버전의 커널과 라이브러리를 유지해야 합니다.
2. 동일한 Public 서브넷과 VPC에서,서로 간 통신할 수 있어야 합 니다.(예를 들어 ping 명령을 통해)
3. 2개 인스턴스 모두 SSH로 원격으로 접근할 수 있어야 합니다.
4. 
   1. Server node 1
      1. 크기 : t2.small
      2. 이미지 : Rocky Linux 9.5
      3. 설치 소프트웨어
         1. Python 3.10
         2. Node 18.0
         3. Java 11.0
         4. Docker engine
   2. Station node 1
         1. 크기 : t2.micro
         2. 이미지 : Rocky Linux 9.5
         3. 설치 소프트웨어
            1. Python 3.10
            2. Node 18.0
            3. Java 11.0
            4. Docker engine
