container-status:
	-@docker-compose ps

container-log:
	-@docker-compose logs

container-stop:
	-@docker-compose down -v

container-start:
	-@make container-stop
	-@docker-compose build
	-@docker-compose up -d
