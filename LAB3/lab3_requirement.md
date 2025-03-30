## 1. 준비하기
이 LAB에서는 AWS에 컨테이너화된 웹 애플리케이션을 배포합니다. 이 애플리케이션은 사용자가 HTTP 요청을 보내고 응답을 받을 수 있도록 엔드포인트를 노출하는 MongoDB 데이터베이스와 API 서버로 구성되어 있습니다. Node.js 애플리케이션과 mongodb 데이터베이스는 분리되어 컨테이너화되어 AWS의 EC2 인스턴스에서 Docker-compose를 사용하여 배포되었습니다. 따라서 엔드포인트는 EC2 인스턴스의 공용 IP를 사용하여 액세스되었습니다.

이 저장소는 두 개의 Dockerfiles(Dockerfile.app 및 Dockerfile.mongodb), 하나의 docker-compose 파일(docker-compose.yml), 하나의 종속성 파일(package.json), 데이터베이스 콘텐츠 파일(KBL-Pitcher-2024.csv, KBL등록 선수 목록 및 통계), nodejs 애플리케이션 코드(app.js) 및 mongobd 컬렉션을 만들고 설정하기 위한 파일들로 구성되어 있습니다.
![이미지](https://github.com/user-attachments/assets/162645b3-e01f-4205-9c40-fa542fb98721)
<br/>
공개 GitHub 저장소의 URL저장소를 복제합니다.
```sh
git clone https://github.com/aws-all-star/aws-labs.git
```
<br/>
필요한 도구를 설치하려면 아래 링크의 단계를 따르십시오.:<br/>
- Docker: https://docs.docker.com/engine/install/
<br/><br/>

## 2. 시작하기
1. 개인 터미널에서 SSH를 통해 EC2 인스턴스로 접근합니다. 인스턴스는 LAB1 에서 생성한 인스턴스 중 하나를 활용합니다.
```sh
ssh -i <YOUR_KEY_PAIR> rocky@<YOUR_EC2_PUBLIC_IP>
```
<br/>

2. duf-utils는 yum-utils CLI 호환성 계층으로서, DNF를 사용하여 새로운 구현을 사용하는 debuginfo-install, groups-manager, repograph, package-cleanup, repoclosure, repomanage, repoquery, reposync, repotrack, builddep, config-manager, debug 및 다운로드를 위한 CLI 공급합니다.
```sh
dnf install dnf-utils
```
<br/>

3. Docker-CE는 Community Edition으로 소규모 프로젝트를 위해 제공되는 오픈된 도커엔진입니다. Containerd는 컨테이너를 실행하고 노드에서 이미지를 관리하는 데 사용되는 오픈소스 컨테이너 런타임입니다. Docker에서 개발되었으며, Kubernetes에서 지원되는 업계 표준 컨테이너 런타임입니다. dnf명령어를 통해 패키지를 설치합니다. 시작하기 전 docker 저장소를 추가해야 합니다.
```sh
dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
dnf install docker-ce docker-ce-cli containerd.io
```
<br/>

4. Docker 및 docker-compose 설치의 경우, 다음 링크를 확인하고 제공된 단계를 진행하십시오.
```sh
curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```
<br/>

5. docker-compose 명령어를 실행하도록 권한을 할당합니다.
```sh
chmod +x /usr/local/bin/docker-compose
```
<br/>

6. 절대경로로 docker-compose 명령어를 실행하도록 합니다.
```sh
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```
<br/>

7. docker와 docker-compose 버전을 확인합니다. 최신버전을 설치하는 것이 여러 오류를 해결할 수 있습니다.
```sh
docker-compose -v
```
<br/>

```sh
docker -v
```
<br/>

8. docker 엔진을 실행 후, 정상적으로 기동되었는지 확인합니다.
```sh
systemctl start docker
systemctl enable docker
```
<br/>

```sh
systemctl status docker
```
<br/>

시작에 앞서 docker hub에 이미지를 올리려면 https://hub.docker.com/ 에 가입해야 합니다. 이후에 터미널에서 docker login 명령어로 로그인을 하도록 합니다. 정상적으로 로그인이 되어야 이후 작업을 완료할 수 있습니다.

9. CD를 올바른 폴더(project_34)에 넣고 다음 명령을 사용하여 docker-compose 파일을 실행하십시오.
```sh
docker-compose up
```
<br/>


## 3. 제출지침
- EC2 인스턴스의 Public IP를 복사하여 아래 모델에 따라 웹 브라우저에 붙여넣고 원하는 출력에 따라 경로를 편집합니다. 3000포트로 접속할 수 있어야 합니다.
- docker 명령어를 통해 컨테이너 상태를 확인할 수 있어야 합니다.
<br/><br/>
