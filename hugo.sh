#!/bin/bash
sed -i "s/[.\/]*_resources/\/images/1"  ./content/$1
cp -n -r /etc/docker/NutstoreFiles/typora-md/_resources/* /etc/docker/hugo/xherror_top/static/images
docker exec -it hugo bash hugo