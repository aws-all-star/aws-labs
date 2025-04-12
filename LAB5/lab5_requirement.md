# 준비하기
Grafana LGTM 스택은 모니터링, 관찰 가능성 및 시각화를 위해 설계된 포괄적인 오픈 소스 도구 세트입니다. 여기에는 몇 가지 주요 구성 요소가 포함되어 있으며, 각각은 애플리케이션 및 인프라 모니터링을 위한 완벽한 솔루션을 제공하는 특정 목적을 제공합니다. Grafana LGTM 스택을 설정하고 kubernetes clsuter에서 작업하는 데 관심이 있다면 이 저장소에 제공된 지침을 따르십시오.

- Loki는 프로메테우스에서 영감을 받은 수평 확장 가능하고 고가용성을 갖춘 다중 테넌트 로그 집계 시스템입니다. 로그 내용을 인덱싱하는 대신 각 로그 스트림에 대한 레이블 세트를 사용하므로 매우 비용 효율적이고 조작하기 쉽도록 설계되었습니다.
- Promtail은 로컬 로그 내용을 Grafana Loki 인스턴스 또는 Grafana Cloud로 전송하는 에이전트입니다. 일반적으로 모니터링해야 하는 애플리케이션이 있는 모든 컴퓨터에 배포됩니다.
- Tempo는 오픈 소스이며 사용하기 쉬운 대규모 분산 추적 백엔드입니다. Tempo는 비용 효율적이며 개체 저장소만 필요로 하며 Grafana, Prometheus 및 Loki와 깊이 통합되어 있습니다. 또한 Jaeger, Zipkin 및 OpenTelemetry를 포함한 일반적인 오픈 소스 추적 프로토콜을 수집할 수 있습니다.

Mimir를 사용하면 고가용성, 다중 테넌시, 내구성 있는 스토리지 및 장기간에 걸쳐 매우 빠른 쿼리 성능을 통해 지표를 10억 개의 활성 시리즈 이상으로 확장할 수 있습니다.

Pyroscope는 Grafana Mimir, Grafana Loki 및 Grafana Tempo와 건축 설계를 조정하는 다중 테넌트 연속 프로파일링 집계 시스템입니다. 이 통합을 통해 프로파일링 데이터와 기존 메트릭, 로그 및 추적을 응집력 있게 상관 관계를 분석할 수 있습니다.



# 시작하기
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
