update_all: docker_push_troll docker_push_gdpr-check docker_push_locust docker_push_doge concourse_update_all docs_make scoreboard_make terraform_controller terraform_app

docs_make:
	cd backing-services; make

scoreboard_make:
	cd scoreboard; make

docker_build_doge:
	cd register-a-doge; docker build -t alexkinnanegds/register-a-doge:latest .

# Need to be logged in to docker
docker_push_doge: docker_build_doge
	docker push alexkinnanegds/register-a-doge:latest

docker_build_locust:
	cd scripts/locust; docker build -t alexkinnanegds/locust:latest .

docker_push_locust: docker_build_locust
	docker push alexkinnanegds/locust:latest

docker_push_gdpr-check:
	cd scripts/gdpr-check; docker build -t alexkinnanegds/gdpr-check:latest .
	docker push alexkinnanegds/gdpr-check:latest




docker_run_troll:
	cd scripts/troll; docker build -t alexkinnanegds/troll:latest .
	docker run alexkinnanegds/troll

docker_push_troll:
	cd scripts/troll; docker build -t alexkinnanegds/troll:latest .
	docker push alexkinnanegds/troll:latest

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

teams=one two three four five six seven
concourse_sp_teams = $(addprefix concourse_sp_, $(teams))
concourse_update_all: $(concourse_sp_teams)

concourse_sp_%:
# cd pipelines; fly -t main dp -n -p team_$*_admin
# cd pipelines; fly -t main dp -n -p team_$*
	cd pipelines; fly -t main set-pipeline -n -c pipeline_admin.yml -p team_$*_admin --load-vars-from team_$*.yml
	cd pipelines; fly -t main set-pipeline -n -c pipeline_public.yml -p team_$* --load-vars-from team_$*.yml
# cd pipelines; fly -t main expose-pipeline -p team_$*
# cd pipelines; fly -t main up -p team_$*
# cd pipelines; fly -t main up -p team_$*_admin

concourse_bt_teams = $(addprefix concourse_bt_, $(teams))
concourse_bt_all: $(concourse_bt_teams)

concourse_bt_%:
	fly -t main trigger-job -j team_$*_admin/base-traffic


terraform_account:
	cd terraform/deployments/gameday-zero/account; terraform apply

# Deploy the application / infrastructure to ALL accounts
# Set up CLI access for arn:aws:iam::redacted:role/bootstrap
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
	cd register-a-doge; bundle install --path vendor/bundle; APP_DIFFICULTY=17 bundle exec rackup

local_smoketest:
	- cd scripts; APP_URL=http://localhost:4567 IDENTIFIER=test APP_DIFFICULTY=17 ./smoke.rb

# Smoke test local app
local_smoke:
	cd register-a-doge; bundle install --path vendor/bundle; APP_DIFFICULTY=17 bundle exec rackup & sleep 3
	- cd scripts; APP_URL=http://localhost:4567 IDENTIFIER=test APP_DIFFICULTY=17 ./smoke.rb
	pkill -9 -f rackup


# Run a smoke test for team 1
smoketest_1:
	cd scripts; APP_URL=https://one.game.gds-reliability.engineering IDENTIFIER=admin_smoke DIFFICULTY=17 ./smoke.rb

# load test team 1
loadtest_1:
	docker pull alexkinnanegds/lt
	docker run alexkinnanegds/lt --target=https://one.game.gds-reliability.engineering/register --rps=3 --duration=1m

local_locust_1: docker_build_locust
	docker run -e AWS_SECRET_ACCESS_KEY=$${AWS_SECRET_ACCESS_KEY} -e AWS_ACCESS_KEY_ID=$$AWS_ACCESS_KEY_ID -e AWS_SESSION_TOKEN=$$AWS_SESSION_TOKEN -e APP_DIFFICULTY=17 -e TEAM=test -e POINTS=1 alexkinnanegds/locust http://localhost:4567


# Build a new load testing image
# docker_build_lt:
# 	cd tests/load-tests; docker build -t alexkinnanegds/lt:latest .

# docker_push_lt: docker_build_lt
# 	docker push alexkinnanegds/lt:latest
