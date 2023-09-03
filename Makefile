run:
	docker-compose up -d encoder

enter:
	docker exec -it encoder zsh

build:
	DOCKER_BUILDKIT=1 docker-compose build encoder

print_setting:
	docker exec -it rabbitmq sh -c "rabbitmqctl environment |grep consumer_timeout"
