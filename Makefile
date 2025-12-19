all :	create-dirs up

up :
		docker compose -f srcs/docker-compose.yml up -d
down :
		docker compose -f srcs/docker-compose.yml down 

fclean :
		docker compose -f srcs/docker-compose.yml down -v
		sudo rm -rf /home/fcarlucc/data/*

re :
		docker compose -f srcs/docker-compose.yml down -v
		sudo rm -rf /home/fcarlucc/data/*
		@echo "Creating directories"
		sudo mkdir -p /home/fcarlucc/data/wordpress
		sudo mkdir -p /home/fcarlucc/data/mariadb
		docker compose -f srcs/docker-compose.yml up --build -d

start :
		docker compose -f srcs/docker-compose.yml start

prune :
		docker system prune -af

create-dirs:
		@echo "Creating directories"
	sudo mkdir -p /home/fcarlucc/data/wordpress
	sudo mkdir -p /home/fcarlucc/data/mariadb