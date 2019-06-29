#!/usr/bin/env bash
set -ueo pipefail

yum -y install jq curl git awslogs docker

mkdir -p /etc/awslogs
mkdir -p /var/awslogs/state

cat <<LOGS > /etc/awslogs/awslogs.conf
[general]
state_file = /var/awslogs/state/agent-state

[/var/log/messages]
file            = /var/log/messages
log_group_name  = app-$(ec2-metadata -i | awk '{print $2}')
log_stream_name = /var/log/messages
datetime_format = %b %d %H:%M:%S
LOGS


sed -i "s/us-east-1/eu-west-2/g" /etc/awslogs/awscli.conf

service awslogsd restart
service docker restart

sleep 2s

docker run \
  --log-driver=awslogs \
  --log-opt awslogs-region=eu-west-2 \
  --log-opt awslogs-group="app-$(ec2-metadata -i | awk '{print $2}')" \
  --restart always \
  -p '8080:4567' \
  -e RACK_ENV=production \
  -e DB_NAME=app \
  -e DB_USERNAME=app \
  -e DB_HOST='${db_host}' \
  -e DB_PASSWORD='${db_password}' \
  -e APP_DIFFICULTY='17' \
  -d \
  --entrypoint rackup \
  alexkinnanegds/register-a-doge:latest
