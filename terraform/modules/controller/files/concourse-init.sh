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
log_group_name  = concourse-$(ec2-metadata -i | awk '{print $2}')
log_stream_name = /var/log/messages
datetime_format = %b %d %H:%M:%S
LOGS

sed -i "s/us-east-1/eu-west-2/g" /etc/awslogs/awscli.conf

service awslogsd restart
service docker restart
systemctl enable docker.service

docker run \
  --log-driver=awslogs \
  --log-opt awslogs-region=eu-west-2 \
  --log-opt awslogs-group="concourse-$(ec2-metadata -i | awk '{print $2}')" \
  --restart always \
  -p '8080:8080' \
  -d \
  --privileged \
  concourse/concourse:5.3 \
  quickstart \
  --postgres-host='${postgres_host}' \
  --postgres-password='${postgres_password}' \
  --postgres-user=concourse \
  --postgres-database=concourse \
  --add-local-user='doge:${local_user_password}' \
  --main-team-local-user=doge \
  --external-url='${external_url}' \
  --cluster-name=doge \
  --worker-ephemeral
