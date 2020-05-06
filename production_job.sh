#!/bin/bash

# Checking if Production Code directory is present
if ! ls /opt/ | grep "prod";then
	## Crate Production Code directory in its absence 
  	sudo mkdir /opt/prod

else
	echo "hey"
    #sudo rm -rf /opt/prod/
fi

# Deploying master branch code to the production environment
sudo cp -ap . /opt/prod/

# Checking if docker dameon is active and running
if ! sudo systemctl status docker >/dev/null ; then
	systemctl start docker
fi

# Checking whether production is already live 
if sudo docker ps  | grep "prod_web" >/dev/null; then
	echo "Production Container already running"

elif sudo docker ps -a | grep "prod_web" >/dev/null; then
	echo "Production container was in stopped state"
    	echo "Starting Production"
    	sudo docker start prod_web

else
	echo "Production is not live. Going on Live now"
	if ! sudo docker network ls | grep "prod_application" >/dev/null; then
    		sudo docker network create --subnet 10.100.20.0/24  --driver bridge prod_application
    	fi
	sudo docker run -dit --network prod_application -v /opt/prod/:/usr/local/apache2/htdocs/ --name prod_web -p 80:80 httpd:alpine

fi


