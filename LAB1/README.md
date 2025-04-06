# LAB 1. AWS Cloud 기반 Linux 서버 구성
클라우드 서버는 클라우드 서비스 제공업체가 소유한 인프라의 클라우드에서 실행되는 가상화된 서버입니다. 기존에는 자체적으로 물리적 서버를 구매하고 유지 관리해야 했습니다. 이 서버는 데이터 처리 및 분석에 필요한 애플리케이션을 실행 및 호스팅하고 워크로드를 계산하는 데 사용되었습니다. 이러한 서버는 온사이트 또는 인근 데이터 센터에 있었습니다. 이제는 전세계 어디에서나 가상 클라우드 서버를 가동할 수 있습니다. 이러한 가상 공간은 타사 클라우드 제공업체에서 구매하고 유지 관리하는 물리적 서버에서 실행됩니다. 가상 서버 복제본 또는 클라우드 서버는 물리적 서버 머신과 동일한 성능, 구성 옵션 및 사용 편의성을 제공합니다. 수백 가지 구성 유형의 클라우드 서버에 무제한으로 액세스할 수 있습니다. 이러한 성능을 바탕으로 클라우드에서 모든 유형의 애플리케이션과 워크로드를 실행하고 호스팅할 수 있습니다.
<br/>
![이미지 6](https://github.com/user-attachments/assets/9402496c-1a7d-4354-b389-e5bbfe86875c)

Linux는 오픈소스 운영 체제(Operating System, OS)로, 세계에서 가장 큰 규모의 오픈소스 소프트웨어 프로젝트 중 하나입니다. Linux 운영 체제는 오픈소스이고 GNU GPL(General Public License)로 제공되므로 누구나 소스 코드를 실행, 분석, 수정, 재배포하고 수정한 코드의 복사본을 판매할 수도 있습니다. 클라우드 컴퓨팅이 등장하고 보편화됨에 따라 Linux는 많은 기업들이 선택하는 클라우드 컴퓨팅 및 클라우드 서비스용 OS로 자리 잡았습니다. 
<br/>

AWS는 세계 최초의 글로벌 클라우드 공급업체이자 가장 높은 시장 점유율을 자랑합니다.1 AWS는 전 세계에 분산된 데이터센터 네트워크를 통해 워크로드 및 애플리케이션을 확장하는 데 필요한 컴퓨팅 용량을 이용할 수 있도록 온디맨드 방식의 보안 중심 가상 액세스 기능을 지원하여 오늘날의 시장 과제에 민첩하게 대응하도록 합니다.
AWS는 Linux OS인 Amazon Linux 2023(AL2023) 최신 버전도 제공합니다. AWS 클라우드에서 애플리케이션을 실행하기 위한 OS로 AL2023을 선택하면 경우에 따라 AWS 무료 티어를 통해 일정 기간 무료로 OS를 이용할 수도 있습니다.
<br/><br/>

## 전제조건
- Linux 서버에 대한 일반 지식
- AWS Cloud 인프라에 대한 이해
- 기본 IT인프라 운영에 대한 관리
</br></br>

## 목표 구성도
<img width="900" alt="image" src="https://github.com/user-attachments/assets/a442b5e7-329a-476c-b7a9-a984118ccbb8" />
<br/><br/>

## 테스트 결과
- 동일한 Public 서브넷과 VPC에서, ping 명령을 통해 서로 간 통신할 수 있어야 합니다 
- 2개 인스턴스 모두 SSH로 원격으로 접근할 수 있어야 합니다.
<br/><br/>

## 저작자
- Kim, Dong Hyun (티스토리) [https://www.linkedin.com/in/kim-donghyun0916/](https://rhlinux.tistory.com)
- Kim, Dong Hyun (Credly) https://www.credly.com/users/kim-donghyun0916
- Kim, Dong Hyun (Lindin) https://www.linkedin.com/in/kim-donghyun0916/
<br/><br/>
