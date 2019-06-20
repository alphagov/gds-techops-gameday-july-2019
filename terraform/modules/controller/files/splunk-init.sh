#!/usr/bin/env bash
set -ueo pipefail

yum -y install jq curl git awslogs docker
amazon-linux-extras install epel
yum -y install epel-release
yum -y install nginx

mkdir -p /etc/awslogs
mkdir -p /var/awslogs/state

cat <<LOGS > /etc/awslogs/awslogs.conf
[general]
state_file = /var/awslogs/state/agent-state

[/var/log/messages]
file            = /var/log/messages
log_group_name  = splunk-$(ec2-metadata -i | awk '{print $2}')
log_stream_name = /var/log/messages
datetime_format = %b %d %H:%M:%S
LOGS

sed -i "s/us-east-1/eu-west-2/g" /etc/awslogs/awscli.conf

service awslogsd restart
service docker restart

docker run \
  --log-driver=awslogs \
  --log-opt awslogs-region=eu-west-2 \
  --log-opt awslogs-group="splunk-$(ec2-metadata -i | awk '{print $2}')" \
  --restart always \
  -p '8000:8000' \
  -p '8088:8088' \
  -p '8089:8089' \
  -d \
  -e SPLUNK_START_ARGS='--accept-license --answer-yes' \
  -e SPLUNK_PASSWORD='${admin_password}' \
  splunk/splunk:latest

mkdir -p /etc/nginx
cat <<EOF > /etc/nginx/nginx.conf
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /tmp/nginx.pid;

events {
  worker_connections 1024;
}

http {
  log_format main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                   '\$status \$body_bytes_sent "\$http_referer" '
                   '"\$http_user_agent" "\$http_x_forwarded_for"';

  access_log /var/log/nginx/access.log  main;

  sendfile            on;
  tcp_nopush          on;
  tcp_nodelay         on;
  keepalive_timeout   65;

  server {
    listen       8080 default_server;
    server_name  _;

    location / {
    proxy_set_header HOST \$host;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_pass     http://localhost:8000;
    proxy_redirect http://${external_host} https://${external_host};
    }
  }
}
EOF

service nginx restart
