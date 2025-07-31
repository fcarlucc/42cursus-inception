all :	create-dirs up

up :
		sudo docker compose -f srcs/docker-compose.yml up --build
down :
		sudo docker compose -f srcs/docker-compose.yml down -v 

fclean :
		sudo docker compose -f srcs/docker-compose.yml down -v
		sudo rm -rf /home/fcarlucc/data/wordpress/*
		sudo rm -rf /home/fcarlucc/data/mariadb/*

re :
		sudo docker compose -f srcs/docker-compose.yml down -v
		sudo docker compose -f srcs/docker-compose.yml up --build

stop :
		sudo docker compose -f srcs/docker-compose.yml stop

start :
		sudo docker compose -f srcs/docker-compose.yml start

prune :
		sudo docker system prune -af

create-dirs:
		@echo "Creating directories"
		mkdir -p /home/fcarlucc/data/wordpress
		mkdir -p /home/fcarlucc/data/mariadb