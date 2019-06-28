docs_make:
	cd backing-services; make

scoreboard_make:
	cd scoreboard; make

docker_build_doge:
	cd register-a-doge; docker build -t alexkinnanegds/register-a-doge:latest .

# Need to be logged in to docker
docker_push_doge: docker_build_doge
	docker push alexkinnanegds/register-a-doge:latest

# Build a new load testing image
docker_build_lt:
	cd tests/load-tests; docker build -t alexkinnanegds/lt:latest .

docker_push_lt: docker_build_lt
	docker push alexkinnanegds/lt:latest

# Build az_failure_image
docker_build_az_failure:
	cd scripts/az_failure; docker build -t alexkinnanegds/az_failure:latest .

docker_push_az_failure: docker_build_az_failure
	docker push alexkinnanegds/az_failure:latest

docker_run_az_failure: docker_build_az_failure
	docker run -e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" -e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" -e AWS_SESSION_TOKEN="${AWS_SESSION_TOKEN}" alexkinnanegds/az_failure

# Update team `one` concourse pipeline
# Download `fly` from concourse landing page
# https://concourse.zero.game.gds-reliability.engineering/api/v1/cli?arch=amd64&platform=linux
# https://concourse.zero.game.gds-reliability.engineering/api/v1/cli?arch=amd64&platform=darwin
# Run login before any other tasks
concourse_login:
	fly login --concourse-url https://concourse.zero.game.gds-reliability.engineering/ -t main

concourse_update_1:
	cd pipelines; fly -t main set-pipeline -c combined.yml -p team-one --load-vars-from variables.yml

# Update all team's concourse pipelines
# You have to be logged in to the concourse instance
concourse_update_all:concourse_update_1

# Update the admin account: route53 / state bucket
terraform_account:
	cd terraform/deployments/gameday-zero/account; terraform apply

# Deploy the application / infrastructure to ALL accounts
# Set up CLI access for arn:aws:iam::277976119446:role/bootstrap
terraform_app:
	cd terraform/deployments/gameday-zero/app-deployments; terraform apply

# Destroy the application / infrastructure in ALL accounts
terraform_app_destroy:
	cd terraform/deployments/gameday-zero/app-destroy; terraform apply

terraform_app_reset: terraform_app_destroy terraform_app

# Update the controller infrastructure
terraform_controller:
	cd terraform/deployments/gameday-zero/controller; terraform apply

terraform_controller_deps: docs_make scoreboard_make terraform_controller

terraform_init:
	cd terraform/deployments/gameday-zero/account; terraform init
	cd terraform/deployments/gameday-zero/app-deployments; terraform init
	cd terraform/deployments/gameday-zero/app-destroy; terraform init
	cd terraform/deployments/gameday-zero/controller; terraform init

# Run register a doge locally
local_runapp:
	cd register-a-doge; bundle install --path vendor/bundle; APP_DIFFICULTY=4 bundle exec rackup & sleep 3s

local_smoketest:
	- cd scripts; APP_URL=http://localhost:4567 IDENTIFIER=test APP_DIFFICULTY=2 ./smoke.rb

# Smoke test local app
local_smoke: local_runapp
	- cd scripts; APP_URL=http://localhost:4567 IDENTIFIER=test APP_DIFFICULTY=2 ./smoke.rb
	pkill -9 -f rackup


# Run a smoke test for team 1
smoketest_1:
	cd scripts; APP_URL=https://one.game.gds-reliability.engineering IDENTIFIER=admin_smoke DIFFICULTY=2 ./smoke.rb

# load test team 1
loadtest_1:
	docker pull alexkinnanegds/lt
	docker run alexkinnanegds/lt --target=https://one.game.gds-reliability.engineering/register --rps=3 --duration=1m

local_locust:
	APP_DIFFICULTY=4 TEAM=two POINTS=1 locust -f scripts/locust.py -c 5 -r 1 --no-web --host http://localhost:4567
