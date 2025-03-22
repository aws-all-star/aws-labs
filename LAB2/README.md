# LAB 2 - API 서버 및 데이터베이스 구축

이 LAB에서는 MongoDB 데이터베이스에 연결된 Nodejs API 마이크로서비스를 배포합니다. 이 API는 사용자가 HTTP 요청을 보내고 JSON 페이로드로 응답을 받을 수 있는 노출된 엔드포인트를 가질 것입이다.

LAB2에서는 AWS CLI를 사용하여 AWS 클라우드 인프라를 배포하는 역할을 합니다. 특히, AWS 아키텍처에는 VPC, 인터넷 게이트웨이, 두 개의 공용 서브넷, 공용 경로 테이블, 공용 EC2 인스턴스, 자동 스케일링 그룹, 애플리케이션 로드 밸런서, 보안 그룹, NAT 게이트웨이, 하나의 개인 서브넷, 개인 경로 테이블 및 개인 EC2 인스턴스가 있습니다. Application Load Balancer는 개방형 시스템 간 상호 연결(OSI) 모델의 일곱 번째 계층인 애플리케이션 계층에서 작동합니다. 로드 밸런서는 요청을 받으면 우선 순위에 따라 리스너 규칙을 평가하여 적용할 규칙을 결정한 다음, 규칙 작업의 대상 그룹에서 대상을 선택합니다. 애플리케이션 트래픽의 콘텐츠를 기반으로 다른 대상 그룹에 요청을 라우팅하도록 리스너 규칙을 구성할 수 있습니다. 대상이 여러 개의 대상 그룹에 등록이 된 경우에도 각 대상 그룹에 대해 독립적으로 라우팅이 수행됩니다. 대상 그룹 레벨에서 사용되는 라우팅 알고리즘을 구성할 수 있습니다. 기본 라우팅 알고리즘은 라운드 로빈입니다. 그 대신 최소 미해결 요청 라우팅 알고리즘을 지정할 수 있습니다.

애플리케이션에 대한 요청의 전체적인 흐름을 방해하지 않고 필요에 따라 로드 밸런서에서 대상을 추가 및 제거할 수 있습니다. 애플리케이션에 대한 트래픽이 시간에 따라 변화하므로 Elastic Load Balancing은 로드 밸런서를 확장합니다. Elastic Load Balancing은 대다수의 워크로드에 맞게 자동으로 조정할 수 있습니다.

로드 밸런서가 정상적인 대상에만 요청을 보낼 수 있도록 등록된 대상의 상태를 모니터링하는 데 사용되는 상태 확인을 구성할 수 있습니다.
![이미지 3](https://github.com/user-attachments/assets/5b159842-7eaa-452c-bc9c-0292d19e34d6)
</br></br>

## 전제조건
- Cloud 인프라 기본 지식
- AWS 아키텍처에 대한 이해
- API와 마이크로서비스 설계 정의
</br></br>

## 목표 아키텍처
<img width="800" alt="image" src="https://github.com/user-attachments/assets/d1fa61b6-05c1-49d1-add6-3422bfc0f6c2" />
</br></br>

## 테스트 결과
"KBL-Pitcher-2024.csv"라는 csv 파일에는 KBL등록된 투수들 중 정규시즌에 20위 순위권 선수, 평균 자책점 , 경기 승리 수에 대한 데이터가 있습니다.

메인 스크립트를 실행한 후 AWS 인프라를 시작한 지역의 콘솔에서 AWS 계정으로 이동하여 EC2 대시보드를 클릭한 다음 로드 밸런서를 클릭합니다. lab2-load-balancer 로드 밸런서를 선택하고 DNS 이름을 복사한 다음 원하는 경로를 따라 웹 브라우저에 붙여넣습니다.

1. 경로 "/" 선택하면, KBL-Pitcher-2024 문서를 모든 내용을 출력합니다.</br>
2. 경로 "/teams" 선택하면, 모든 팀의 목록을 출력합니다.
3. 경로 "/players/top/10" 선택하면, ERA(평균 자책점) 가장 낮은 10명에 선수를 출력합니다.
</br></br>

## 저작자
- Kim, Dong Hyun (티스토리) [https://www.linkedin.com/in/kim-donghyun0916/](https://rhlinux.tistory.com)
- Kim, Dong Hyun (Credly) https://www.credly.com/users/kim-donghyun0916
- Kim, Dong Hyun (Lindin) https://www.linkedin.com/in/kim-donghyun0916/
<br/><br/>
