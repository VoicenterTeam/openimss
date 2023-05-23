#!/bin/bash

echo '###### Building openimss_open5gs ######'
cd base

docker build --no-cache --force-rm -t docker_openimss_open5gs .

cd ../ims_base

echo '###### Building openimss_opensips ######'
docker build --no-cache --force-rm -t docker_openimss_opensips .


cd ../srslte


echo '###### Building openimss_opensips ######'
docker build --no-cache --force-rm -t docker_openimss_srslte .

cd ..

set -a
source .env

docker-compose build --no-cache

echo '###### Starting Docker compose ######'

docker-compose up -d


