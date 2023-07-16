---
title: "使用acme.sh在nginx安装SSL证书"
description: 原创
date: 2023-07-16T02:33:09Z
image: acme.png
math: 
license: 
hidden: false
comments: true
categories:
    - SEC
---
之前使用腾讯云的SSL证书进行部署，简单方便。但免费证书仅有1年使用时间，过期需要重新签发，且由于DNS解析与服务器部署使用不同的账号，SSL证书还需要自行下载部署，过于麻烦。因此决定尝试采用acme.sh来签发SSL证书，记录一下全过程。

1. nginx安装与初步配置

采用docker-compose安装nginx，初步配置文件如下，实现反向代理到三个内部container

````yml
#docker-compose.yml
services:
  nginx:
    restart: always
    container_name: nginx
    image: nginx:latest
    volumes:
      - "/etc/docker/nginx/nginx.conf:/etc/nginx/nginx.conf"
      - "/var/log/nginx:/var/log/nginx"
    ports:
      - "80:80"
      - "443:443"
````

```nginx
#nginx.conf
user nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /var/run/nginx.pid;



events {
    worker_connections  1024;
}


http {
    client_max_body_size 20m;
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    keepalive_timeout  65;

    include /etc/nginx/conf.d/nginx.conf;

    #hugo static content
    server {
        listen 80;
        server_name www.xherror.top xherror.top;
    }
 
    #filebrowser 
    server {
        listen 80;
        server_name drive.xherror.top;
    }

    #mailu
    server {
        listen 80;
        server_name mail.xherror.top;
    }
   

```

```shell
#启动container
$ docker-compose up -d
```

2. container配置与SSL证书签发

进入container中，进行必要的安装

```shell
# 国内服务器进行换源
$ sed -i s@http://deb.debian.org@http://mirrors.aliyun.com@g /etc/apt/sources.list \
    && rm -Rf /var/lib/apt/lists/* && apt-get update && apt-get -y install cron vim

# crontab初始化
$ crontab -e 
no crontab for root
installing new crontab

# email需要填写，不然后续签发会有问题
$ curl https://get.acme.sh | sh -s email=my@example.com
[Tue Jul  4 05:05:31 UTC 2023] Installing from online archive.
[Tue Jul  4 05:05:31 UTC 2023] Downloading https://github.com/acmesh-official/acme.sh/archive/master.tar.gz
[Tue Jul  4 05:05:32 UTC 2023] Extracting master.tar.gz
[Tue Jul  4 05:05:32 UTC 2023] It is recommended to install socat first.
[Tue Jul  4 05:05:32 UTC 2023] We use socat for standalone server if you use standalone mode.
[Tue Jul  4 05:05:32 UTC 2023] If you don't use standalone mode, just ignore this warning.
[Tue Jul  4 05:05:32 UTC 2023] Installing to /root/.acme.sh
[Tue Jul  4 05:05:32 UTC 2023] Installed to /root/.acme.sh/acme.sh
[Tue Jul  4 05:05:32 UTC 2023] Installing alias to '/root/.profile'
[Tue Jul  4 05:05:32 UTC 2023] OK, Close and reopen your terminal to start using acme.sh
[Tue Jul  4 05:05:32 UTC 2023] Installing cron job
[Tue Jul  4 05:05:32 UTC 2023] Good, bash is found, so change the shebang to use bash as preferred.
[Tue Jul  4 05:05:33 UTC 2023] OK
[Tue Jul  4 05:05:33 UTC 2023] Install success!

# 多域名签发相同SSL证书
$ /root/.acme.sh/acme.sh --issue --nginx -d xherror.top -d drive.xherror.top -d mail.xherror.top
-----END CERTIFICATE-----
[Tue Jul  4 05:15:25 UTC 2023] Your cert is in: /root/.acme.sh/xherror.top_ecc/xherror.top.cer
[Tue Jul  4 05:15:25 UTC 2023] Your cert key is in: /root/.acme.sh/xherror.top_ecc/xherror.top.key
[Tue Jul  4 05:15:25 UTC 2023] The intermediate CA cert is in: /root/.acme.sh/xherror.top_ecc/ca.cer
[Tue Jul  4 05:15:25 UTC 2023] And the full chain certs is there: /root/.acme.sh/xherror.top_ecc/fullchain.cer
```

3. nginx二次配置与证书部署

配置nginx.conf，实现HTTP重定位到HTTPS，并将请求发送给内部的container服务器

```shell
#filebrowser 
    server {
        listen 80;
        server_name drive.xherror.top;
        return 301 https://$host$request_uri; 
        
    }
    server {
        #SSL 访问端口号为 443
        client_max_body_size 300m;
        listen 443 ssl; 
        #填写绑定证书的域名
        server_name drive.xherror.top;
        #证书文件名称
        ssl_certificate cert/xherror.top.cer; 
        #私钥文件名称
        ssl_certificate_key cert/xherror.top.key; 
        ssl_session_timeout 5m;
        #请按照以下协议配置
        ssl_protocols TLSv1.2 TLSv1.3; 
        #请按照以下套件配置，配置加密套件，写法遵循 openssl 标准。
        ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE; 
        ssl_prefer_server_ciphers on;
        location / {
            proxy_pass  http://172.28.0.3:80; 
            proxy_set_header Host $proxy_host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
```

```shell
$  mkdir /etc/nginx/cert 

# 证书 部署
$ /root/.acme.sh/acme.sh --install-cert -d xherror.top -d drive.xherror.top -d mail.xherror.top \
--key-file       /etc/nginx/cert/xherror.top.key  \
--fullchain-file /etc/nginx/cert/xherror.top.cer \
--reloadcmd     "service nginx force-reload"
```

之后尝试将整合操作成sh，或做成新镜像避免每次都要重新配置





https://github.com/acmesh-official/acme.sh



https://www.owq.world/7a1dd44c/



https://cloud.tencent.com/document/product/400/35244