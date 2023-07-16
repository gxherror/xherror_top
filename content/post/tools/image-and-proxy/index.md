---
title: "docker中常用镜像与代理"
description: 
date: 2022-10-13T04:32:28Z
image: 
math: 
license: 
hidden: false
comments: true
categories:
 -  TOOLS
 -  LINUX
 -  DOCKER
---
## docker镜像站

Docker Engine中添加

```
{
  "registry-mirrors": [
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com"
  ]
}
```

## image的构建

### apt-get

```dockerfile
#debian平台 
RUN sed -i s@http://deb.debian.org@http://mirrors.aliyun.com@g /etc/apt/sources.list \
    && rm -Rf /var/lib/apt/lists/* && apt-get update
#Ubuntu平台
RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list \
	&& sed -i s@/security.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list \
    && rm -Rf /var/lib/apt/lists/* && apt-get update
```

### pip

```dockerfile
#全局pip镜像
RUN pip config set global.index-url https://mirror.sjtu.edu.cn/pypi/web/simple
#单次pip镜像
RUN pip install -i https://mirror.sjtu.edu.cn/pypi/web/simple numpy
```

### conda

https://www.cnblogs.com/dereen/p/anaconda_tencent_mirrors.html

```dockerfile
RUN /root/anaconda3/bin/conda update conda -y \
	&& echo "channels:" > ~/.condarc \
	&& echo " - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/" >> ~/.condarc \
	&& echo " - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/" >> ~/.condarc \
	&& echo " - https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/" >> ~/.condarc \
	&& echo "ssl_verify: true" >> ~/.condarc \
	# 忽略 ttyname failed: Inappropriate ioctl for device 错误
	&& sed -i -e 's/mesg n .*true/tty -s \&\& mesg n/g' ~/.profile \
	&& cat ~/.condarc \
```

### git,wget,curl

https://ghproxy.com/

```dockerfile
RUN git clone https://ghproxy.com/https://github.com/stilleshan/ServerStatus
RUN wget https://ghproxy.com/源uri
RUN curl -O https://ghproxy.com/源uri
#sed替换文件请求的uri
RUN sed -i "s/https:\/\/github.com/https:\/\/ghproxy.com\/https:\/\/github.com/1" file
```

### docker

https://dockerproxy.com/

### go

https://github.com/goproxy/goproxy.cn/blob/master/README.zh-CN.md

```dockerfile
RUN go env -w GO111MODULE=on \
	&& go env -w GOPROXY=https://goproxy.cn,direct
```



