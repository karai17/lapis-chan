#!/usr/bin/env bash

docker-compose --env-file ./.env.test up --abort-on-container-exit
