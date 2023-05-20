#!/bin/bash


cd docker_open5gs/base

docker build --no-cache --force-rm -t docker_open5gs .

cd ../srslte

docker build --no-cache --force-rm -t docker_srslte .

cd ..

set -a
source .env

docker-compose build --no-cache

docker-compose up