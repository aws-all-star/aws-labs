# 1. 준비하기
프로메테우스(Prometheus)와 그라파나(Grafana)는 모니터링을 위한 도구입니다. 프로메테우스는 상태 데이터를 수집하고, 그라파나는 프로메테우스로 수집한 데이터를 관리자가 보기 좋게 시각화합니다. 컨테이너 인프라 환경에서는 많은 종류의 소규모 기능이 각각 나누어 개발되기 때문에 중앙 모니터링이 필요합니다. 이때 효율적으로 모니터링하는 방법 중 하나가 프로메테우스와 그라파나의 조합입니다. 프로메테우스와 그라파나는 컨테이너로 패키징돼 동작하며 최소한의 자원으로 쿠버네티스 클러스터의 상태를 시각적으로 표현합니다. <br/>

모니터링 데이터 수집 도구는 프로메테우스 외에도 데이터독(DataDog), 인플럭스DB(InfluxDB), 뉴 렐릭(New Relic) 등이 있지만, 오픈 소스를 활용하는 기업은 프로메테우스 외에 다른 선택지가 없을 정도로 가장 탁월한 효율을 자랑합니다.
<br/>

데이터를 시각화하는 도구는 그라파나 외에도 키바나(Kibana), 크로노그래프(Chronograf) 등이 있으나 업계에서는 그라파나와 키바나가 시장을 양분한 상태입니다. 하지만 키바나는 프로메테우스와 연결 구성이 복잡하므로 프로메테우스를 사용할 때는 간결하게 구성할 수 있는 그라파나를 더 선호합니다.

- Grafana: 모니터링 및 관찰 가능성을 위한 오픈 소스 플랫폼. 이를 통해 지표를 쿼리하고, 시각화하고, 경고하고, 이해할 수 있습니다.
- Loki: 프로메테우스에서 영감을 받은 수평으로 확장 가능한 고가용성 다중 테넌트 로그 집계 시스템입니다.
- Promtail: 로컬 로그의 내용을 개인 로키 인스턴스 또는 그라파나 클라우드로 보내는 에이전트입니다.
- Promethus: 오픈 소스 시스템 모니터링 및 경고 툴킷입니다.
- Node Expoter: 플러그 가능한 메트릭 수집기가 있는 하드웨어 및 OS 메트릭을 위한 Promethus Expoter입니다.
<br/>

이 LAB에서는 Prometheus, Grafana, Loki 및 Promtail과 같은 오픈 소스 도구를 사용하여 AWS EKS에서 모니터링 및 로깅을 설정하는 포괄적인 가이드를 제공합니다. 여기에는 원활한 애플리케이션 성능과 효과적인 로그 관리를 보장하기 위해 설치, 구성 및 배포에 대한 자세한 지침이 포함되어 있습니다.

# 2. 시작하기
1. Promethus 와 Grafana 를 위한 Helm Chart 저장소(repository)를 시스템에 추가합니다.<br/>
```sh
kubectl create namespace monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring
```
<br/>

2. Helm을 사용하여 EKS 클러스터에 Prometheus를 설치하세요. Kube-prometheus-stack 차트는 Alertmanager, node exporter 등과 같은 관련 구성 요소와 함께 Prometheus를 설치합니다.
```sh
helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace
```
<br/>

3. 다음으로, Grafana를 설치하여 Prometheus가 수집한 지표를 시각화합니다.
```sh
helm install grafana grafana/grafana --namespace monitoring
```
<br/>

4. 모니터링 네임스페이스에 포드를 나열하여 Prometheus와 Grafana가 모두 성공적으로 설치되었는지 확인하십시오.
```sh
kubectl get pods -n monitoring
```
<br/>

5. 포트 포워딩을 사용하여 Grafana에 액세스하십시오: 아래 명령을 실행한 다음 웹 브라우저에서 http://127.0.0.1:8080/을 입력하십시오. 사용자는 admin 이고 비밀번호는 아래 명령어로도 확인할 수 있습니다.<br/>
`kubectl --namespace monitoring get secrets monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo`
<br/>

```sh
kubectl port-forward service/monitoring-grafana 8080:80 -n monitoring
```
<br/>

6. Kube-Prometheus-Stack에는 클러스터를 모니터링할 수 있는 많은 대시보드가 있습니다. Grafana의 "대시보드" 섹션에서 액세스할 수 있습니다. 또한 클러스터 지표를 더 잘 시각화하기 위해 15757 대시보드를 가져올 것을 제안합니다. 이 외에도 사용자 환경에 맞게 선택하세요.
<br/>

7. 이제, 로키를 설치하세요:<br/>
```sh
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade --install loki --namespace=monitoring grafana/loki-stack --set grafana.enabled=false --set loki.enabled=true --set loki.promtail.enabled=true
```
<br/>

URL http://loki:3100을 사용하여 Grafana에서 Loki를 데이터 소스로 추가합니다. 그런 다음 로그 시각화를 위해 대시보드 ID 12611을 가져옵니다.<br/>
