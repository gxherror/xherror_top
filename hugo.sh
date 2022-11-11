#!/bin/bash
sed -i "s/[.\/]*_resources/\/images/1"  ./content/$1
cp -n -r /etc/docker/Nutstore\ Files/typora-md/_resources/* /etc/docker/hugo/xherror_top/static/images
docker exec -it e77c73dba3c1 bash hugo