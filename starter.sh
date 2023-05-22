#!/bin/bash


cd base

docker build --no-cache --force-rm -t docker_openimss_open5gs .

cd ../srslte

docker build --no-cache --force-rm -t docker_openimss_srslte .

cd ..

set -a
source .env

docker-compose build --no-cache

docker-compose up
