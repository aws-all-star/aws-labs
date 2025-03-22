
git clone https://github.com/aws-all-star/aws-labs.git

dnf install dnf-utils

yum install docker-ce docker-ce-cli containerd.io


curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose


ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose


docker-compose -v


docker -v

systemctl start docker


systemctl status docker

