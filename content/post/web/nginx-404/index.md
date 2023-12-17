---
title: "一次NIGNX 404错误排查"
description: 记录
date: 2023-10-31T18:29:12Z
image: 
math: 
license: 
hidden: false
comments: true
categories:
    - WEB
tags:
---
## 问题描述

跟往常一样，正准备更新点东西到博客，一打开博客404 not found 就蒙了，几天前还一切正常，这几天也没改nginx相关的配置，记录一下排查过程，避免之后在遇到相同问题

![image-20231101014817383](/images/image-20231101014817383.png)

## nginx日志

查看nginx日志，发现nginx的access.log没有最新的记录，而error.log也没有记录，这种情况下怀疑是nginx配置问题

```bash
# access.log
111.30.182.95 - - [30/Oct/2023:10:33:21 +0000] "GET / HTTP/1.1" 301 169 "-" "DNSPod-Monitor/2.0" "-"
180.149.125.171 - - [30/Oct/2023:10:34:22 +0000] "GET / HTTP/1.1" 200 615 "-" "Mozilla/5.0 (Windows NT 5.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.90 Safari/537.36" "-"
101.89.45.22 - - [30/Oct/2023:10:34:45 +0000] "GET / HTTP/1.1" 301 169 "-" "DNSPod-Monitor/2.0" "-"
# 没有最新操作记录
```

## nginx配置问题

404报错先检查是不是nginx静态文件找不到了，先是检查docker挂载文件一切正常，进入容器，检查文件权限没有问题，再注释掉301重定位直接访问80端口也是404，`nginx -s reload`也不行，`docker restart`或者删除重建容器都不行，连nginx的欢迎界面都没有，就去检查网络连接是不是有问题

```nginx
#hugo static content
server {
    listen 80;
    server_name www.xherror.top xherror.top;
    return 301 https://$host$request_uri; 
}
server {
    listen 443 ssl; 
    server_name www.xherror.top  xherror.top; 
    ssl_certificate cert/xherror.top.cer; 
    ssl_certificate_key cert/xherror.top.key; 
    ssl_session_timeout 5m;
    ssl_protocols TLSv1.2 TLSv1.3; 
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE; 
    ssl_prefer_server_ciphers on;
    location / {
        root /etc/nginx/public;        
        index index.html;
        error_page 404 404.html;

    }
}
```

## docker网络

进行如下所示测试，感觉网络互通没有问题，还是容器到主机的端口映射存在问题，但是在**关闭容器后curl仍然是404，这就不对劲了，正常状态应该是refused才对**，`ss`指令抓80端口，也没看到有进程监听端口，实在不知道怎么回事，开始胡乱Google相关的例子

```bash
# 在宿主机中
$docker port nginx
80/tcp -> 0.0.0.0:80
443/tcp -> 0.0.0.0:443
$curl 127.0.0.1:80
404 not found 
$curl 192.168.128.2:80 #容器IP，正常返回

# 容器中
$curl 127.0.0.1:80  #正常返回
$curl 172.17.0.1:80 #宿主机IP，404
404 not found 

# 关闭容器后
$curl 127.0.0.1:80 #不对劲
404 not found 
$ss -tpunl |grep :80 #没有进程监听80
```

## 检查iptables

Google到一片文章提到可能是iptables配置问题，发现以下记录，猛然想起前几天在**k8s配置了一个Service映射了80端口**，`kubectl delete service `一切问题解决了:)

```bash
Chain CNI-DN-c3cb834a70ca0380906b7 (1 references)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 CNI-HOSTPORT-SETMARK  tcp  --  *      *       10.42.0.0/24         0.0.0.0/0            tcp dpt:80
   36  2064 CNI-HOSTPORT-SETMARK  tcp  --  *      *       127.0.0.1            0.0.0.0/0            tcp dpt:80
   38  2184 DNAT       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:80 to:10.42.0.8:80
    0     0 CNI-HOSTPORT-SETMARK  tcp  --  *      *       10.42.0.0/24         0.0.0.0/0            tcp dpt:443
   17  1020 CNI-HOSTPORT-SETMARK  tcp  --  *      *       127.0.0.1            0.0.0.0/0            tcp dpt:443
   17  1020 DNAT       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:443 to:10.42.0.8:443
```

## 总结

- 把k8s与Docker分开，不放在同一台主机上，有k8s情况下Docker只作为CRI
- 研究一下为什么`ss`不显示Service的端口映射，Docker中的端口映射都会以`users:(("docker-proxy",pid=XXXXX,fd=4)`作为端口监听进程

