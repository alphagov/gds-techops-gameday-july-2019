docker_build_doge:
	cd register-a-doge; docker build -t alexkinnanegds/register-a-doge:latest .

docker_push_doge: docker_build_doge
	cd register-a-doge; docker push alexkinnanegds/register-a-doge:latest

docker_build_lt:
	cd tests/load-tests; docker build -t alexkinnanegds/lt:latest .

docker_push_lt: docker_build_lt
	cd tests/load-tests; docker push alexkinnanegds/lt:latest

concourse_update_1:
	cd pipelines; fly -t main set-pipeline -c combined.yml -p team-one --load-vars-from variables.yml

concourse_update_all: concourse_update_1

terraform_account:
	cd terraform/deployments/gameday-zero/account; terraform apply

terraform_app:
	cd terraform/deployments/gameday-zero/app-deployments; terraform apply

terraform_controller:
	cd terraform/deployments/gameday-zero/controller; terraform apply

terraform_init:
	cd terraform/deployments/gameday-zero/account; terraform init
	cd terraform/deployments/gameday-zero/app-deployments; terraform init
	cd terraform/deployments/gameday-zero/controller; terraform init

local_runapp:
	cd register-a-doge; bundle install --path vendor/bundle; APP_DIFFICULTY=2 bundle exec rackup & sleep 3s

local_smoketest: local_runapp
	- cd scripts; APP_URL=http://localhost:4567 IDENTIFIER=test APP_DIFFICULTY=2 time ./smoke.rb
	pkill -9 -f rackup

smoketest_1:
	cd scripts; APP_URL=https://one.game.gds-reliability.engineering IDENTIFIER=admin_smoke DIFFICULTY=2 ./smoke.rb

loadtest_1:
	docker pull alexkinnanegds/lt
	docker run alexkinnanegds/lt --target=https://one.game.gds-reliability.engineering/register --rps=2 --duration=1m
