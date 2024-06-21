#!/bin/bash

case $1 in
"down")
	docker compose \
		-f docker-compose.base.yaml \
		-f docker-compose.dev.yaml down
	;;
"dev")
	docker compose \
		-f docker-compose.base.yaml \
		-f docker-compose.dev.yaml up -d
	;;

"prod")
	docker compose \
		-f docker-compose.base.yaml \
		-f docker-compose.prod.yaml up -d --build
	;;
*)
	echo "Commands: down|dev|prod"
	;;
esac


