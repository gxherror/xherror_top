#!/bin/bash
sed -i "s/[.\/]*_resources/\/images/p"  ./content/$1
cp -n -r /etc/docker/images/ /etc/docker/hugo/xherror_top/static/
docker exec -it e77c73dba3c1 bash hugo