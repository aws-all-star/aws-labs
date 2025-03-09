# LAB 4 - 옵저버빌리티(Observability) 시스템

이 프로젝트는 공용 인터넷에서 사용자가 소비할 수 있는 4개의 작업자 노드 클라우드 프로덕션 쿠버네티스 클러스터(EKS)에 컨테이너화된 웹 앱을 배포합니다. 컨테이너의 오케스트레이션은 쿠버네티스 스택을 사용하여 이루어지며, 클러스터는 옵저버빌리티 시스템(Grafana, Loki for logs, and Prometheus for metrics)에 의해 적극적으로 모니터링됩니다.

이 저장소는 두 개의 배포 YAML 파일(app-deployment.yaml, mongo-deployment.yaml)과 두 개의 서비스 YAML 파일(app-service.yaml, mongo-service.yaml)로 구성되어 있습니다. 배포 매니페스트는 Nodejs 애플리케이션과 mongoDB 데이터베이스를 다른 포드에 배포하는 역할을 하지만, 서비스 매니페스트는 네트워크를 통해 파드를 노출하고, 논리적 엔드포인트 세트를 정의하고, 해당 포드에 접근 가능한 방법에 대한 정책을 정의하는 역할을 합니다.

이 README 파일은 EKS 클러스터, 웹 애플리케이션 및 관찰 가능성 시스템을 시작하는 단계를 간략하게 설명합니다.
