---
title: "Thingsboard二次开发"
description: 项目
date: 2023-11-30T14:10:07Z
image: 
math: 
license: 
hidden: false
comments: true
categories:
    - BIOT
tags:
---
## 开发

- 开发环境为WSL2:ubuntu20.04,IDE为VSCODE与IDEA混用
- 项目要求需要修改thingsboard的ui前端与后端,进行tb的二次开发
- tb版本3.6.1

```shell
$uname -a
Linux WIN-UAIGFBGM66P 5.15.90.1-microsoft-standard-WSL2 #1 SMP Fri Jan 27 02:56:13 UTC 2023 x86_64 x86_64 x86_64 GNU/Linux

$free -h
               total        used        free      shared  buff/cache   available
Mem:            23Gi       2.6Gi        16Gi        65Mi       4.5Gi        20Gi

# https://thingsboard.io/docs/user-guide/install/ubuntu/
# 安装环境
$java --version
openjdk 11.0.21 2023-10-17
OpenJDK Runtime Environment (build 11.0.21+9-post-Ubuntu-0ubuntu122.04)
OpenJDK 64-Bit Server VM (build 11.0.21+9-post-Ubuntu-0ubuntu122.04, mixed mode, sharing)

$mvn -v
Apache Maven 3.6.3
Maven home: /usr/share/maven
Java version: 11.0.21, vendor: Ubuntu, runtime: /usr/lib/jvm/java-11-openjdk-amd64
Default locale: en, platform encoding: UTF-8
OS name: "linux", version: "5.15.90.1-microsoft-standard-wsl2", arch: "amd64", family: "unix"

# clone
$git clone -b release-3.6 git@github.com:thingsboard/thingsboard.git --depth 1
$cd thingsboard

# https://thingsboard.io/docs/user-guide/contribution/how-to-contribute/
# ui热更新开发
$cd ${TB_WORK_DIR}/ui-ngx
$mvn clean install -P yarn-start

# 二次开发后编译
# 编译后在application/target可以看到deb与rpm包
$mvn clean install -DskipTests -Dlicense.skip=true #-Ddockerfile.skip=false
...
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  10:42 min
[INFO] Finished at: 2023-11-27T15:14:18+08:00
[INFO] ------------------------------------------------------------------------


```

### 换LOGO

替换`ui-ngx/src/assets/logo_title_white.svg`文件

### 换标题

```ts
// ui-ngx/src/environments/environment.ts
export const environment = {
  appTitle: 'Your_title',
  production: false,
// @ts-ignore
  tbVersion: TB_VERSION,
// @ts-ignore
  supportedLangs: SUPPORTED_LANGS,
  //! 设置为zh_CN会有问题
  defaultLang: 'en_US'
};

// ui-ngx/src/index.html
<head>
  <meta charset="utf-8">
  <title>Your_title</title>
  <base href="/">
  ...
</head>
  
```

### 侧边栏调整

见另一篇文章





## 部署

- 部署环境为centos7,**内存为8G(内存偏小导致后续出现很多问题QAQ)**

### 整体(monolithic)

```shell
$java --version
openjdk 11.0.21 2023-10-17 LTS
OpenJDK Runtime Environment (Red_Hat-11.0.21.0.9-1.el7_9) (build 11.0.21+9-LTS)
OpenJDK 64-Bit Server VM (Red_Hat-11.0.21.0.9-1.el7_9) (build 11.0.21+9-LTS, mixed mode, sharing)

$mvn -v
Apache Maven 3.9.5 (57804ffe001d7215b5e7bcb531cf83df38f93546)
Maven home: /opt/apache-maven-3.9.5
Java version: 11.0.21, vendor: Red Hat, Inc., runtime: /usr/lib/jvm/java-11-openjdk-11.0.21.0.9-1.el7_9.x86_64
Default locale: en_US, platform encoding: UTF-8
OS name: "linux", version: "3.10.0-1160.71.1.el7.x86_64", arch: "amd64", family: "unix"

# https://thingsboard.io/docs/user-guide/install/rhel/
# 安装编译后的rpm包
$sudo rpm -Uvh thingsboard.rpm

# pg12采用docker-compose安装
#注意pg镜像版本为12
$cat docker-compose.yml
services:
  tb-postgres:
    image: postgres:12.17-bullseye
    container_name: tb-postgres
    restart: always
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: PUT_YOUR_POSTGRESQL_PASSWORD_HERE
      POSTGRES_DB: thingsboard
    ports:
      - 5432:5432
      
# 配置tb
$sudo nano /etc/thingsboard/conf/thingsboard.conf
# DB Configuration 
export DATABASE_TS_TYPE=sql
export SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/thingsboard
export SPRING_DATASOURCE_USERNAME=postgres
export SPRING_DATASOURCE_PASSWORD=PUT_YOUR_POSTGRESQL_PASSWORD_HERE
# Specify partitioning size for timestamp key-value storage. Allowed values: DAYS, MONTHS, YEARS, INDEFINITE.
export SQL_POSTGRES_TS_KV_PARTITIONING=MONTHS

# 注意到该文件为软链接文件
$ls -al /etc/thingsboard/
...
lrwxrwxrwx    1 root root    27 Nov 29 17:54 conf -> /usr/share/thingsboard/conf

$sudo /usr/share/thingsboard/bin/install/install.sh --loadDemo
$sudo service thingsboard start
$sudo service thingsboard status
Redirecting to /bin/systemctl status  -l thingsboard.service
● thingsboard.service - thingsboard
   Loaded: loaded (/usr/lib/systemd/system/thingsboard.service; enabled; vendor preset: disabled)
   Active: active (running) since Mon 2023-12-11 14:11:21 CST; 5 days ago
 Main PID: 7314 (thingsboard.jar)
    Tasks: 234
   Memory: 1.1G
   CGroup: /system.slice/thingsboard.service
           ├─7314 /bin/bash /usr/share/thingsboard/bin/thingsboard.jar
           └─7331 /usr/bin/java -Dsun.misc.URLClassPath.disableJarChecking=true -Dplatform=rpm -Dinstall.data_dir=/usr/share/thingsboard/data -Xlog:gc*,heap*,age*,safepoint=debug:file=/var/log/thingsboard/gc.log:time,uptime,level,tags:filecount=10,filesize=10M -XX:+IgnoreUnrecognizedVMOptions -XX:+HeapDumpOnOutOfMemoryError -XX:-UseBiasedLocking -XX:+UseTLAB -XX:+ResizeTLAB -XX:+PerfDisableSharedMem -XX:+UseCondCardMark -XX:+UseG1GC -XX:MaxGCPauseMillis=500 -XX:+UseStringDeduplication -XX:+ParallelRefProcEnabled -XX:MaxTenuringThreshold=10 -jar /usr/share/thingsboard/bin/thingsboard.jar
   
# 之后可以通过8080访问
```


#### 问题

```shell
$psql -U postgres -h 127.0.0.1 -p 5432 -d postgres
SCRAM authentication requires libpq version 10
```

vscode插件MySQL连接pg问题,当pg>12时会出现 =.=



```log
[INSERT INTO ts_kv (entity_id, key, ts, bool_v, str_v, long_v, dbl_v, json_v) VALUES (?, ?, ?, ?, ?, ?, ?, cast(? AS json)) ON CONFLICT (entity_id, key, ts) DO UPDATE SET bool_v = ?, str_v = ?, long_v = ?, dbl_v = ?, json_v = cast(? AS json);]; nested exception is org.postgresql.util.PSQLException: ERROR: relation "ts_kv" does not exist
```

重新创建thingsboard数据库 =.=



```shell
$ sudo docker run -it -p 10000:10000 hello-world
docker: Error response from daemon: driver failed programming external connectivity on endpoint quirky_ganguly (daeddaf282ab974b4adec8d4c2b67974032b6ccd9af8a3bd4b2c8df8fbfdec53):  (iptables failed: iptables --wait -t nat -A DOCKER -p tcp -d 0/0 --dport 10000 -j DNAT --to-destination 172.17.0.3:10000 ! -i docker0: iptables: No chain/target/match by that name.
 (exit status 1)).
```

docker restart =.=

### 前后分离

https://www.jianshu.com/p/54f441459185

https://www.iotschool.com/topics/247

https://github.com/chainingning/thingsboard-ui-vue

根据搜到的资料`yarn start`后进程收到`SIGKILL`,无法完成build过程,排除问题是**内存占用过大=.=**

tb前端为Angular SPA,纯粹的静态文件,发现**前端请求先发到了后端4200,node后端进行4200->8080的转发,需要修改前端的请求路径或者自己再做一个转发的web后端**,尝试使用lite-server作为web后端转发请求,调试不出结果:(,由于对前端js不熟不知如何修改,放弃这种方案

### 微服务

https://github.com/blackstar-baba/how-2-use-thingsboard/blob/main/doc/%E9%83%A8%E7%BD%B2/%E5%BE%AE%E6%9C%8D%E5%8A%A1.md

https://thingsboard.io/docs/user-guide/install/cluster/docker-compose-setup/

一开始直接使用官方的配置文件启动集群,服务器崩了:(

使用`docker stats`查看发现**集群占用内存过大**,之后尝试**删除冗余节点,容器加资源限制**,不是内存过小跑不动就是内存过大达到服务器上限,放弃微服务部署:(

```yml
version: '3.0'
services:
  zookeeper:
    restart: always
    image: "zookeeper:3.8.0"
    ports:
      - "2181"
    environment:
      ZOO_MY_ID: 1
      ZOO_SERVERS: server.1=zookeeper:2888:3888;zookeeper:2181
      ZOO_ADMINSERVER_ENABLED: "false"
  tb-js-executor:
    restart: always
    image: "${DOCKER_REPO}/${JS_EXECUTOR_DOCKER_NAME}:${TB_VERSION}"
    deploy:
      replicas: 10
    env_file:
      - tb-js-executor.env
  tb-core1:
    restart: always
    image: "${DOCKER_REPO}/${TB_NODE_DOCKER_NAME}:${TB_VERSION}"
    ports:
      - "8080"
      - "7070"
    logging:
      driver: "json-file"
      options:
        max-size: "200m"
        max-file: "30"
    environment:
      TB_SERVICE_ID: tb-core1
      TB_SERVICE_TYPE: tb-core
      EDGES_ENABLED: "true"
      JAVA_OPTS: "${JAVA_OPTS}"
    env_file:
      - tb-node.env
    volumes:
      - ./tb-node/conf:/config
      - ./tb-node/log:/var/log/thingsboard
    depends_on:
      - zookeeper
      - tb-js-executor
      - tb-rule-engine1
  tb-rule-engine1:
    restart: always
    image: "${DOCKER_REPO}/${TB_NODE_DOCKER_NAME}:${TB_VERSION}"
    ports:
      - "8080"
    logging:
      driver: "json-file"
      options:
        max-size: "200m"
        max-file: "30"
    environment:
      TB_SERVICE_ID: tb-rule-engine1
      TB_SERVICE_TYPE: tb-rule-engine
      JAVA_OPTS: "${JAVA_OPTS}"
    env_file:
      - tb-node.env
    volumes:
      - ./tb-node/conf:/config
      - ./tb-node/log:/var/log/thingsboard
    depends_on:
      - zookeeper
      - tb-js-executor
  tb-mqtt-transport1:
    restart: always
    image: "${DOCKER_REPO}/${MQTT_TRANSPORT_DOCKER_NAME}:${TB_VERSION}"
    ports:
      - "1883"
    environment:
      TB_SERVICE_ID: tb-mqtt-transport1
      JAVA_OPTS: "${JAVA_OPTS}"
    env_file:
      - tb-mqtt-transport.env
    volumes:
      - ./tb-transports/mqtt/conf:/config
      - ./tb-transports/mqtt/log:/var/log/tb-mqtt-transport
    depends_on:
      - zookeeper
      - tb-core1
  tb-http-transport1:
    restart: always
    image: "${DOCKER_REPO}/${HTTP_TRANSPORT_DOCKER_NAME}:${TB_VERSION}"
    ports:
      - "8081"
    environment:
      TB_SERVICE_ID: tb-http-transport1
      JAVA_OPTS: "${JAVA_OPTS}"
    env_file:
      - tb-http-transport.env
    volumes:
      - ./tb-transports/http/conf:/config
      - ./tb-transports/http/log:/var/log/tb-http-transport
    depends_on:
      - zookeeper
      - tb-core1
  tb-web-ui1:
    restart: always
    image: "${DOCKER_REPO}/${WEB_UI_DOCKER_NAME}:${TB_VERSION}"
    ports:
      - "8080"
    env_file:
      - tb-web-ui.env
  tb-vc-executor1:
    restart: always
    image: "${DOCKER_REPO}/${TB_VC_EXECUTOR_DOCKER_NAME}:${TB_VERSION}"
    ports:
      - "8081"
    environment:
      TB_SERVICE_ID: tb-vc-executor1
      JAVA_OPTS: "${JAVA_OPTS}"
    env_file:
      - tb-vc-executor.env
    volumes:
      - ./tb-vc-executor/conf:/config
      - ./tb-vc-executor/log:/var/log/tb-vc-executor
    depends_on:
      - zookeeper
      - tb-core1
  haproxy:
    restart: always
    container_name: "${LOAD_BALANCER_NAME}"
    image: thingsboard/haproxy-certbot:2.2.31-alpine3.18
    volumes:
     - ./haproxy/config:/config
     - ./haproxy/letsencrypt:/etc/letsencrypt
     - ./haproxy/certs.d:/usr/local/etc/haproxy/certs.d
    ports:
     - "80:80"
     - "443:443"
     - "1883:1883"
     - "7070:7070"
     - "9999:9999"
    cap_add:
     - NET_ADMIN
    environment:
      HTTP_PORT: 80
      HTTPS_PORT: 443
      MQTT_PORT: 1883
      EDGES_RPC_PORT: 7070
      FORCE_HTTPS_REDIRECT: "false"
    links:
        - tb-core1
        - tb-web-ui1
        - tb-mqtt-transport1
        - tb-http-transport1
```

#### 问题

```
Error: Specified qdisc not found
```

**WSL2的问题**,需要添加内核支持



```
[Question] 503 Service Unavailable - Cluster setup with Docker Compose
```

https://github.com/thingsboard/thingsboard/issues/8279

However, the VM might run out of memory to become so slow. So we see 503 Service Unavailable from Web UI again.


## 更新

```bash
# 会保留配置文件
# 解决Error processing condition on org.thingsboard.server.cache.TBRedisStandaloneConfiguration

# for ubuntu $sudo dpkg -r thingsboard
$sudo rpm -e thingsboard
# for ubuntu $dpkg -l '*thingsboard*'
$ rpm -qa |grep thing
# for ubuntu $sudo dpkg -i thingsboard
$ sudo rpm -ivh thingsboard.rpm 
$ cat /usr/share/thingsboard/conf/thingsboard.conf
# DB Configuration 
...
export DATABASE_TS_TYPE=sql
export SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:54320/thingsboard
export SPRING_DATASOURCE_USERNAME=postgres
export SPRING_DATASOURCE_PASSWORD=postgres
# Specify partitioning size for timestamp key-value storage. Allowed values: DAYS, MONTHS, YEARS, INDEFINITE.
export SQL_POSTGRES_TS_KV_PARTITIONING=MONTHS
# change JWT time 
export JWT_TOKEN_EXPIRATION_TIME=604800

$ cd ~
$ sudo /usr/share/thingsboard/bin/install/install.sh
Unexpected error during ThingsBoard installation!
org.thingsboard.server.dao.exception.DataValidationException: User with email 'sysadmin@thingsboard.org'  already present in database!

$ sudo service thingsboard start
Redirecting to /bin/systemctl start thingsboard.service
$ sudo service thingsboard status
```

## 代理

https://app.zerossl.com/dashboard

https://www.landiannews.com/archives/93605.html

https://github.com/tinkernels/zerossl-ip-cert

- 注意由于没有域名只能用**ZeroSSL**签署免费的SSL证书,不能用Let's Encrypt(certbot/Nginx Proxy Manager使用的)

- nginx in container, 172.17.0.1为宿主机IP

  - ```shell
    $ifconfig
    docker0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
            inet 172.17.0.1  netmask 255.255.0.0  broadcast 172.17.255.255
    ```

- `-v "/etc/docker/nginx/nginx.conf:/etc/nginx/nginx.conf" `,注意挂载的文件,一开始挂载错了导致一系列问题:(

```yml 
#docker-compose.yml 
services: 
  tb-nginx: 
    restart: always 
    container_name: tb-nginx 
    image: nginx:latest 
    volumes: 
    - "/home/thingsboard/docker/nginx/nginx.conf:/etc/nginx/nginx.conf" 
    - "/home/thingsboard/docker/nginx/log:/var/log/nginx" 
    - "/home/thingsboard/docker/nginx/cert:/etc/nginx/cert" 
    ports: 
    - "8088:80" 
    - "4433:443"
```



```nginx
#nginx.conf
server {
    listen 80;
    server_name YOUR_IP YOUR_DOMAIN localhost;
    # 注意这里最后有/
    location /proxy/ {
        # 注意这里最后也有/
        proxy_pass http://172.17.0.1:8081/; 
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location / {
        proxy_pass http://172.17.0.1:8080; 
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}

server {
    listen 443 ssl;
    server_name YOUR_IP YOUR_DOMAIN localhost;
    #证书文件名称
    ssl_certificate cert/certificate.crt;
    #私钥文件名称
    ssl_certificate_key cert/private.key;
    ssl_session_timeout 5m;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE;
    ssl_prefer_server_ciphers on;
    # 注意这里最后有/
    location /proxy/ {
        # 注意这里最后也有/
        proxy_pass http://172.17.0.1:8081/;
        proxy_set_header Host $proxy_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
    location /update/  {
        proxy_pass http://172.17.0.1:4321/;
        proxy_set_header Host $proxy_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
    location / {
        proxy_pass http://172.17.0.1:8080;
        proxy_set_header Host $proxy_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

### 问题

```
nginx: [warn] conflicting server name "localhost" on 0.0.0.0:80, ignored
```

```nginx
http {
    ...
    #配置文件中包括一个defalut.conf,冲突了=.=,注释掉
    #include /etc/nginx/conf.d/*.conf;
    ...
}
```



https://www.reddit.com/r/nginx/comments/6l51to/nginx_warn_conflicting_server_name_mydomaincom_on/

## 总结

- 宝塔面板与Nginx Proxy Manager
- 主域名 ghproxy.com 已喜提 GFW，已启用镜像站 [mirror.ghproxy.com](https://mirror.ghproxy.com/)

https://thingsboard.io/docs/getting-started-guides/helloworld/

http://www.yuhangwei.com/web/note/2021-07-28/68.html

https://zhuanlan.zhihu.com/p/418978795