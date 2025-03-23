# 준비하기
이전 LAB 4의 README 파일(https://github.com/caroldelwing/WCD-DevOps/edit/main/LAB4/README.md)의 단계에 따라 AWS EKS 클러스터를 설정하고 다음 매개변수를 개인화합니다.
<br/>

필요한 도구를 설치하려면 아래 링크의 단계를 따르십시오.
- AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
- Git: https://git-scm.com/book/en/v2/Getting-Started-Installing-Git
- Kubectl: https://kubernetes.io/docs/tasks/tools/
- Docker: https://docs.docker.com/engine/install/
- Helm: https://helm.sh/docs/intro/install/
<br/><br/>

# 시작하기
모니터링 네임스페이스를 만들고 클러스터에 프로메테우스와 그라파나를 설치하는 역할을 하는 쿠베-프로메테우스 스택을 설치하세요.<br/>
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
