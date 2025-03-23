# 준비하기
이 LAB에서는 Public 환경에서 사용자가 사용할 수 있는 4개의 Worker 노드 클라우드 프로덕션 쿠버네티스 클러스터(EKS)에 컨테이너화된 웹 앱을 배포합니다. <br/>
컨테이너의 오케스트레이션은 쿠버네티스 스택을 사용하여 이루어지며, 클러스터는 관찰 가능성 시스템(로그를 위한 그라파나, 로키, 메트릭을 위한 프로메테우스)에 의해 적극적으로 모니터링됩니다.
<br/>
이 저장소는 두 개의 배포 YAML 파일(app-deployment.yaml, mongo-deployment.yaml)과 두 개의 서비스 YAML 파일(app-service.yaml, mongo-service.yaml)로 구성되어 있습니다. 배포 매니페스트는 Nodejs 애플리케이션과 mongoDB 데이터베이스를 다른 포드에 배포하는 역할을 하지만, 서비스 매니페스트는 네트워크를 통해 파드를 노출하고, 논리적 엔드포인트 세트를 정의하고, 해당 포드에 접근 가능한 방법에 대한 정책을 정의하는 역할을 합니다.<br/>
<br/>
이전 실습한 LAB 4의 README 파일(https://github.com/caroldelwing/WCD-DevOps/edit/main/LAB4/README.md)의 단계에 따라 AWS EKS 클러스터를 설정하고 다음 매개변수를 개인화합니다.
<br/>

필요한 도구를 설치하려면 아래 링크의 단계를 따르십시오.
- AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
- Git: https://git-scm.com/book/en/v2/Getting-Started-Installing-Git
- Kubectl: https://kubernetes.io/docs/tasks/tools/
- Docker: https://docs.docker.com/engine/install/
- Helm: https://helm.sh/docs/intro/install/
<br/><br/>

# 시작하기
1. 모니터링 네임스페이스를 만들고 클러스터에 Promethus와 Grafana를 설치하는 역할을 하는 쿠베-프로메테우스 스택을 설치하세요.<br/>
```sh
kubectl create namespace monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring
```
<br/>

포트 포워딩을 사용하여 Grafana에 액세스하십시오: 아래 명령을 실행한 다음 웹 브라우저에서 http://127.0.0.1:8080/을 입력하십시오. 사용자는 관리자이고 비밀번호는 prom-operator입니다.<br/>
```sh
kubectl port-forward service/monitoring-grafana 8080:80 -n monitoring
```
<br/>
Kube-Prometheus-Stack에는 클러스터를 모니터링할 수 있는 많은 대시보드가 있습니다. Grafana의 "대시보드" 섹션에서 액세스할 수 있습니다. 또한 클러스터 지표를 더 잘 시각화하기 위해 다음 대시보드를 가져올 것을 제안합니다: 15757, 15758, 15759 및 15760.

이제, 로키를 설치하세요:<br/>
```sh
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade --install loki --namespace=monitoring grafana/loki-stack --set grafana.enabled=false --set loki.enabled=true --set loki.promtail.enabled=true
```
<br/>
URL http://loki:3100을 사용하여 Grafana에서 Loki를 데이터 소스로 추가합니다. 그런 다음 로그 시각화를 위해 대시보드 ID 12611을 가져옵니다.<br/>
