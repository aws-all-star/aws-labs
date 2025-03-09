# LAB 1. AWS Cloud 기반 Linux 서버 구성
이 LAB에서는 AWS CLI 명령줄 도구와 Bash Shell 스크립트를 사용하여 AWS 클라우드 인프라를 배포합니다. AWS 클라우드 환경에는 VPC, 인터넷 게이트웨이, 공용 서브넷, 공용 경로 테이블 및 두 개의 EC2 인스턴스가 있습니다. EC2 인스턴스는 동일한 공용 서브넷과 VPC에 있어야 하며, 서로 연결할 수 있고, SSH로 원격으로 액세스할 수 있어야 합니다. 또한 모든 인스턴스는 커널 버전과 라이브러리를 최신으로 유지할 수 있어야 합니다.
<br/><br/>

# 목표 구성도
<img width="900" alt="image" src="https://github.com/user-attachments/assets/a442b5e7-329a-476c-b7a9-a984118ccbb8" />
<br/><br/>

1. 동일한 Public 서브넷과 VPC에서, 서로 간 통신할 수 있어야 합니다.(예를 들어 ping 명령을 통해)
2. 2개 인스턴스 모두 SSH로 원격으로 접근할 수 있어야 합니다.
3. 모든 Linux 서버는 최신 버전의 커널과 라이브러리를 유지해야 합니다.
4. tuned 설치 소프트웨어를 설치하고 tuned-adm 명령어를 통해 aws 프로파일을 적용합니다.
<br/><br/>

# 저작자
- Kim, Dong Hyun (티스토리) [https://www.linkedin.com/in/kim-donghyun0916/](https://rhlinux.tistory.com)
- Kim, Dong Hyun (Credly) https://www.credly.com/users/kim-donghyun0916
