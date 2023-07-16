---
title: DOCKER学习
description: 转载
date: 2022-06-26
slug: learn-docker-01
image: 
categories:
    - TOOLS
    - DOCKER
---
[来源](https://yeasy.gitbook.io/docker_practice/)

# Container
#### 当利用 docker run 来创建容器时，Docker 在后台运行的标准操作包括：
- 检查本地是否存在指定的镜像，不存在就从 registry 下载
- 利用镜像创建并启动一个容器
- 分配一个文件系统，并在只读的镜像层外面挂载一层可读写层
- 从宿主主机配置的网桥接口中桥接一个虚拟接口到容器中去
- 从地址池配置一个 ip 地址给容器
- 执行用户指定的应用程序
- 执行完毕后容器被终止
#### `--detach , -d`
Run container in background and print container ID
#### `docker container ls` 
命令来查看容器信息。
#### `docker container logs` 
命令要获取容器的输出信息。
####  `docker container stop` 
来终止一个运行中的容器。此外，当 Docker 容器中指定的应用终结时，容器也自动终止,用户通过 exit 命令或 Ctrl+d 来退出终端时，所创建的容器立刻终止。
#### `docker attach [OPTIONS] CONTAINER`
如果从这个 stdin 中 exit，会导致容器的停止
#### `docker exec [OPTIONS] CONTAINER COMMAND [ARG...]`
从这个 stdin 中 exit，不会导致容器的停止
#### `$ docker container prune`
删除所有处于终止状态的容器
#### `docker save` will indeed produce a tarball, but with all parent layers, and all tags + versions.

#### `docker export` does also produce a tarball, but without any layer/history.
>It is often used when one wants to "flatten" an image, as illustrated in "Flatten a Docker container or image" from Thomas Uhrig:

#### `docker import` creates one image from one tarball which is not even an image (just a filesystem you want to import as an image)
>Create an empty filesystem image and import the contents of the tarball

#### `docker load` creates potentially multiple images from a tarred repository (since docker save can save multiple images in a tarball).
>Loads a tarred repository from a file or the standard input stream



# Image
#### pull
```
$ docker pull [选项] [Docker Registry 地址[:端口号]/]仓库名[:标签]
$ docker pull ubuntu:18.04->docker.io/library/ubuntu:18.04
```
#### `docker commit [OPTIONS] CONTAINER [REPOSITORY[:TAG]]`Create a new image from a container's changes
- 使用 docker commit 意味着所有对镜像的操作都是黑箱操作，生成的镜像也被称为 黑箱镜像，换句话说，就是除了制作镜像的人知道执行过什么命令、怎么生成的镜像，别人根本无从得知。
- 使用 docker commit 制作镜像，以及后期修改的话，每一次修改都会让镜像更加臃肿一次，所删除的上一层的东西并不会丢失，会一直如影随形的跟着这个镜像，即使根本无法访问到。


# Dockerfile
- Dockerfile 是一个文本文件，其内包含了一条条的 指令(Instruction)，**每一条指令构建一层(每一条指令后相当于docker commit)**，因此每一条指令的内容，就是描述该层应当如何构建。
 ```
FROM scratch
...
```
- 如果你以 scratch 为基础镜像的话，意味着你不以任何镜像为基础，接下来所写的指令将作为镜像第一层开始存在。
- 不以任何系统为基础，直接将可执行文件复制进镜像的做法并不罕见，对于 Linux 下静态编译的程序来说，并不需要有操作系统提供运行时支持，所需的一切库都已经在可执行文件里了，因此直接 FROM scratch 会让镜像体积更加小巧。使用 Go 语言 开发的应用很多会使用这种方式来制作镜像，这也是为什么有人认为 Go 是特别适合容器微服务架构的语言的原因之一。
- `docker build [OPTIONS] PATH | URL | -`
- 一般来说，应该会将 Dockerfile 置于一个空目录下，或者项目根目录下。如果该目录下没有所需文件，那么应该把所需文件复制一份过来。如果目录下有些东西确实不希望构建时传给 Docker 引擎，那么可以用 .gitignore 一样的语法写一个 .dockerignore，该文件是用于剔除不需要作为上下文传递给 Docker 引擎的。\
#### CMD
```
#CMD 指令的格式和 RUN 相似，也是两种格式：
#shell 格式：CMD <命令>
#exec 格式：CMD ["可执行文件", "参数1", "参数2"...]
---------------------------------------------------
CMD echo $HOME  -->   CMD [ "sh", "-c", "echo $HOME" ]
```
- Docker 不是虚拟机，容器中的应用都应该以前台执行，而不是像虚拟机、物理机里面那样，用 systemd 去启动后台服务，容器内没有后台服务的概念。
```
CMD service nginx start -->   CMD [ "sh", "-c", "service nginx start"]
```
- 因此主进程实际上是 sh。那么当 service nginx start 命令结束后，sh 也就结束了，sh 作为主进程退出了，自然就会令容器退出
- 正确的做法是直接执行 nginx 可执行文件，并且要求以前台形式运行。比如：
```
CMD ["nginx", "-g", "daemon off;"]
```
#### ENTRYPOINT
- ENTRYPOINT 的目的和 CMD 一样，都是在指定容器启动程序及参数。
- ENTRYPOINT 在运行时也可以替代，不过比 CMD 要略显繁琐，需要通过 docker run 的参数 --entrypoint 来指定。
- 当指定了 ENTRYPOINT 后，CMD 的含义就发生了改变，不再是直接的运行其命令，而是将 CMD 的内容作为参数传给 ENTRYPOINT 指令，换句话说实际执行时，将变为：
```Dockerfile
FROM ubuntu:18.04

RUN apt-get update \
    && apt-get install -y curl \
    && rm -rf /var/lib/apt/lists/*
    
CMD [ "curl", "-s", "http://myip.ipip.net" ]
```
```bash
$ docker build -t myip .
$ docker run myip
当前 IP：61.148.226.66 来自：北京市 联通
$ docker run myip -i
docker: Error response from daemon: ...
//-i 被当做新的CMD，错误 
----------------------------------------------
CMD [ "curl", "-s", "http://myip.ipip.net" ]
-->
ENTRYPOINT [ "curl", "-s", "http://myip.ipip.net" ]
$ docker run myip -i
HTTP/1.1 200 OK
...
//-i 作为CMD被传递给了ENTRYPOINT 
```
- [应用运行前的准备工作](https://yeasy.gitbook.io/docker_practice/image/dockerfile/entrypoint#chang-jing-er-ying-yong-yun-hang-qian-de-zhun-bei-gong-zuo)
#### ENV
```
ENV VERSION=1.0 DEBUG=on \
    NAME="Happy Feet"
```
- 下列指令可以支持环境变量展开： ADD、COPY、ENV、EXPOSE、FROM、LABEL、USER、WORKDIR、VOLUME、STOPSIGNAL、ONBUILD、RUN。
- 可以从这个指令列表里感觉到，环境变量可以使用的地方很多，很强大。通过环境变量，我们可以让一份 Dockerfile 制作更多的镜像，只需使用不同的环境变量即可。
#### VOLUME 定义匿名卷
```Dockerfile
VOLUME /data
```
这里的 /data 目录就会在容器运行时自动挂载为匿名卷，任何向 /data 中写入的信息都不会记录进容器存储层，从而保证了容器存储层的无状态化。当然，运行容器时可以覆盖这个挂载设置。比如：
#### EXPOSE 暴露端口
- EXPOSE 指令是声明容器运行时提供服务的端口，这只是一个声明，在容器运行时并不会因为这个声明应用就会开启这个端口的服务。
- `docker run -P` 时，会自动随机映射 EXPOSE 的端口
- -p，是映射宿主端口和容器端口，换句话说，就是将容器的对应端口服务公开给外界访问，而 EXPOSE 仅仅是声明容器打算使用什么端口而已，并不会自动在宿主进行端口映射。
#### WORKDIR 指定工作目录
```Dockerfile
RUN cd /app  --> WORKDIR /app
RUN echo "hello" > world.txt
```
#### Dockerfile 多阶段构建



# Docker Compose 
![062335697e14f5e40c8a1ce347467dbf.png](062335697e14f5e40c8a1ce347467dbf.png)
- Compose 定位是 「定义和运行多个 Docker 容器的应用（Defining and running multi-container Docker applications）」
- Compose允许用户通过一个单独的 docker-compose.yml 模板文件（YAML 格式）来定义一组相关联的应用容器为一个项目（project）。
- Compose 中有两个重要的概念：
	* 服务 (service)：一个应用的容器，实际上可以包括若干运行相同镜像的容器实例。
	* 项目 (project)：由一组关联的应用容器组成的一个完整业务单元，在 docker-compose.yml 文件中定义。
- Compose 的默认管理对象是项目，通过子命令对项目中的一组容器进行便捷地生命周期管理。
#### 常用指令
```yaml
docker-compose up  #启动所有容器
docker-compose up -d  #后台启动并运行所有容器
docker-compose up --no-recreate -d  #不重新创建已经停止的容器
docker-compose stop  #停止容器
docker-compose start  #启动容器
docker-compose down #停止并销毁容器
```
#### Compose 模板文件
`Dockerfile:`
```Dockerfile
FROM python:3.6-alpine
ADD . /code
WORKDIR /code
RUN pip install redis flask
CMD ["python", "app.py"]
```
`docker-compose.yml:`
```Yaml
version: '3'
services:

  web:
    build: .
    ports:
     - "5000:5000"

  redis:
    image: "redis:alpine"
```
# REFER
- https://github.com/wangduanduan/wangduanduan.github.io/issues/324
- https://yeasy.gitbook.io/docker_practice/