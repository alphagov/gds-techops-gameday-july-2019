serve: down
	docker-compose up -d
	sleep 1
	docker-compose ps

down:
	docker-compose down

build: down
	docker-compose down
	docker-compose build --no-cache

smoketest:
	ruby smoketest.rb
