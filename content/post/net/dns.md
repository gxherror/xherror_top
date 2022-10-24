---
title: "DNS"
description: 学习
date: 2022-10-24T14:44:17Z
image: 
math: 
license: 
hidden: false
comments: true
categories:
    - NET
tags:
---
# DNS基础

- DNS协议使用UDP和TCP(TCP用于长报文)，端口53
- DNS解析优先级：DNS缓存>hosts>DNS服务(hosts：the static table lookup for host name)

## DNS缓存

Linux上，除非已安装并运行诸如Systemd-Resolved，DNSMasq或Nscd之类的缓存服务，否则没有操作系统级DNS缓存。根据Linux发行版和所使用的缓存服务，清除DNS缓存的过程有所不同。

- 使用Systemd-Resolved作为DNS缓存,大多数现代Linux发行版的选择

```
$systemctl status systemd-resolved //查看DNS缓存是否为systemd-resolved
$sudo systemd-resolve --flush-caches //清除系统解析的DNS缓存
```

- 使用Dnsmasq作为DNS缓存,Dnsmasq是轻量级的DHCP和DNS缓存名称服务器

```
$sudo systemctl restart dnsmasq.service
$sudo service dnsmasq restart
```

- Nscd是一个缓存守护程序，它是大多数基于RedHat的发行版的首选DNS缓存系统

```
$sudo systemctl restart nscd.service
$sudo service nscd restart
```

- WIN10

```
$ipconfig /flushdns
Windows IP Configuration

Successfully flushed the DNS Resolver Cache.
```

## hosts

```
//a sample /etc/hosts file
IPAddress	Hostname	Alias
127.0.0.1	localhost	deep.openna.com
208.164.186.1	deep.openna.com	deep
208.164.186.2	mail.openna.com	mail
208.164.186.3	web.openna.com	web
```

After you are finished configuring your networking files, don't forget to restart your network for the changes to take effect.

```
$/etc/rc.d/init.d/network restart
```

## DNS服务

 以systemd-resolve为例,在Linux主机上,我们会通过`/etc/resolv.conf`来指定DNS客户端方面的配置

 ```
$ cat /etc/resolv.conf

nameserver 127.0.0.53
options edns0
search gemfield.org
 ```

- nameserver,也就是DNS服务器地址
- options字段的语法为options option ... 
- 这里配置的是`search http://gemfield.org`，这样，当你在浏览器输入` http://x99`的时候，DNS可以去查询`x99.gemfield.org`的IP。

```
$ sudo ss -autpn| grep 127.0.0.53
udp   UNCONN    0      0               127.0.0.53%lo:53                 0.0.0.0:*                    users:(("systemd-resolve",pid=60518,fd=12))                
tcp   LISTEN    0      4096            127.0.0.53%lo:53                 0.0.0.0:*                    users:(("systemd-resolve",pid=60518,fd=13))     
```

可知该文件由`systemd-resolve`进程维护,主机的表面DNS服务器为`127.0.0.53:53`   ,实际的DNS服务器可通过下面指令获得,为`192.168.0.1`

```
$systemd-resolve --status | grep "DNS Servers"
192.168.0.1
```


### DNS分级查询

![c4464787eb0ea2b9db37234dd8ed2d1](/images/c4464787eb0ea2b9db37234dd8ed2d1.jpg)![2f073547c8d3baaac74abdff755e49b](../../_resources/2f073547c8d3baaac74abdff755e49b.jpg)
![c4464787eb0ea2b9db37234dd8ed2d1](/images/c4464787eb0ea2b9db37234dd8ed2d1.jpg)![2f073547c8d3baaac74abdff755e49b](../../_resources/2f073547c8d3baaac74abdff755e49b.jpg)



## EDNS

- EDNS(extention DNS)就是在遵循已有的DNS消息格式的基础上增加一些字段，来支持更多的DNS请求业务。

### 为什么需要EDNS

- The restrictions in the size of several flags fields, return codes and label types available in the basic DNS protocol prevented the support of some desirable features.
- DNS messages carried by UDP were restricted to 512 bytes

EDNS中引入了一种新的伪资源记录OPT（Resource Record），之所以叫做伪资源记录是因为它不包含任何DNS数据，OPT RR不能被cache、不能被转发、不能被存储在zone文件中。OPT被放在DNS通信双方（requestor和responsor）DNS消息的Additional data区域中
![1ff37915d29d9a13bd0ad84c501a00e8.png](/images/1ff37915d29d9a13bd0ad84c501a00e8.png)
![1ff37915d29d9a13bd0ad84c501a00e8.png](/images/1ff37915d29d9a13bd0ad84c501a00e8.png)

## MDNS

- mDNS 是一种组播 UDP 服务，用来提供本地网络服务和主机发现。
- mdns 即多播dns（Multicast DNS），mDNS主要实现了在没有传统DNS服务器的情况下使局域网内的主机实现相互发现和通信，使用的端口为5353，遵从dns协议，使用现有的DNS信息结构、名语法和资源记录类型。
- 多播地址224.0.0.251

# DNS报文

![c6f164de281986ee192c2897799ae99.jpg](/images/c6f164de281986ee192c2897799ae99.jpg)
![c6f164de281986ee192c2897799ae99.jpg](/images/c6f164de281986ee192c2897799ae99.jpg)

## Flags字段

![75576d18026b297a0d62c3ac74315917.png](/images/75576d18026b297a0d62c3ac74315917.png)
![75576d18026b297a0d62c3ac74315917.png](/images/75576d18026b297a0d62c3ac74315917.png)

- QR（Response）：查询请求/响应的标志信息。查询请求时，值为 0；响应时，值为 1。
  Opcode：操作码。其中，0 表示标准查询；1 表示反向查询；2 表示服务器状态请求.
- AA（Authoritative）：授权应答，该字段在响应报文中有效。值为 1 时，表示名称服务器是权威服务器；值为 0 时，表示不是权威服务器。
- TC（Truncated）：表示是否被截断。值为 1 时，表示响应已超过 512 字节并已被截断，只返回前 512 个字节。
- RD（Recursion Desired）：期望递归。该字段能在一个查询中设置，并在响应中返回。该标志告诉名称服务器必须处理这个查询，这种方式被称为一个递归查询。如果该位为 0，且被请求的名称服务器没有一个授权回答，它将返回一个能解答该查询的其他名称服务器列表。这种方式被称为迭代查询。
- RA（Recursion Available）：可用递归。该字段只出现在响应报文中。当值为 1 时，表示服务器支持递归查询。
- Z：保留字段，在所有的请求和应答报文中，它的值必须为 0。
- rcode（Reply code）：返回码字段，表示响应的差错状态。当值为 0 时，表示没有错误；当值为 1 时，表示报文格式错误（Format error），服务器不能理解请求的报文；当值为 2 时，表示域名服务器失败（Server failure），因为服务器的原因导致没办法处理这个请求；当值为 3 时，表示名字错误（Name Error），只有对授权域名解析服务器有意义，指出解析的域名不存在；当值为 4 时，表示查询类型不支持（Not Implemented），即域名服务器不支持查询类型；当值为 5 时，表示拒绝（Refused），一般是服务器由于设置的策略拒绝给出应答，如服务器不希望对某些请求者给出应答。

## 资源记录(RR)

![b4453a50930ffa22a59ab0b0c4d24dba.png](/images/b4453a50930ffa22a59ab0b0c4d24dba.png)
![b4453a50930ffa22a59ab0b0c4d24dba.png](/images/b4453a50930ffa22a59ab0b0c4d24dba.png)

![Screenshot from 2022-07-06 20-20-54.png](/images/Screenshot from 2022-07-06 20-20-54.png)
![Screenshot from 2022-07-06 20-20-54.png](/images/Screenshot from 2022-07-06 20-20-54.png)





# 常见DNS 记录

- A 记录 - 保存域的 IP 地址的记录`(foo.com,IPv4,A,TTL)`
- AAAA 记录 - 包含域的 IPv6 地址的记录`(foo.com,IPv6,AAAA,TTL)`
- CNAME 记录 - 将一个域或子域转发到另一个域，不提供 IP 地址`(foo.com,fooooo.com,CNAME,TTL)`
- MX 记录 - 将邮件定向到电子邮件服务器`(foo.com,mail.foo.com,MX,TTL)`
- NS 记录 - 存储 DNS 条目的名称服务器。用于TLD服务器查询权威域服务器`(foo.com,dns.foo.com,NS,TTL)`
- SOA 记录 - 存储域的管理信息,主DNS服务器
- PTR 记录 - 在反向查询中提供域名



- TXT 记录 - 可让管理员在记录中存储文本注释。这些记录通常用于电子邮件安全。

<div class="record-table">
<table>
<tbody><tr>
<th>example.com</th>
<th>record type:</th>
<th>value:</th>
<th>TTL</th>
</tr>
<tr>
<td>@</td>
<td>TXT</td>
<td>This is an awesome domain! Definitely not spammy.</td>
<td>32600</td>
</tr>
</tbody></table>
</div>


- 今天，DNS TXT 记录的两个最重要的用途是防止垃圾邮件和域所有权验证
- 大部分时间，TXT 记录是用来做 SPF 反垃圾邮件的。最典型的 SPF 格式的 TXT 记录例子为 `v=spf1 a mx ip4:your_ip -all`，表示只有这个域名的 A 记录和 MX 记录中的 IP 地址有权限使用这个域名发送邮件
  - SPF，全称为 Sender Policy Framework，即发件人策略框架。
  - 根据 SMTP 的规则，发件人的邮箱地址是可以由发信方任意声明的。在 SMTP 协议制定的时候也许还好，但在垃圾和诈骗邮件横行的今天，这显然是极不安全的，SPF 出现的目的，就是为了防止随意伪造发件人。
  - 假设邮件服务器收到了一封邮件，来自主机的 IP 是`173.194.72.103`，并且声称发件人为`email@example.com`。为了确认发件人不是伪造的，邮件服务器会去查询example.com的 SPF 记录。如果该域的 SPF 记录设置允许 IP 为`173.194.72.103`的主机发送邮件，则服务器就认为这封邮件是合法的；如果不允许，则通常会退信，或将其标记为垃圾/仿冒邮件。

- SRV 记录 - 指定用于特定服务的端口。

![1eab7419b334922d7f37b86f722f9f0e.png](/images/1eab7419b334922d7f37b86f722f9f0e.png)
![1eab7419b334922d7f37b86f722f9f0e.png](/images/1eab7419b334922d7f37b86f722f9f0e.png)

- 主机记录：服务的**名字.协议**的类型。例如，设置为` _sip._tcp`。
- 记录类型：选择 `SRV`。
- 线路类型：选择 “默认” 类型，否则会导致部分用户无法解析。
- 记录值：**优先级 权重 端口 主机名**。记录生成后会自动在域名后面补一个 `.`。
  例如，设置为 `0 5 5060 sipserver.example.com`。
- MX 优先级：不需要填写。
- TTL：为缓存时间，数值越小，修改记录各地生效时间越快，默认为600秒。

# 参考

https://blog.csdn.net/qq_42900996/article/details/118105551

https://www.cloudflare.com/zh-cn/learning/dns/dns-records/#:~:text=DNS%20%E8%AE%B0%E5%BD%95%EF%BC%88%E5%8F%88%E5%90%8D%E5%8C%BA%E5%9F%9F,DNS%20%E6%9C%8D%E5%8A%A1%E5%99%A8%E6%89%A7%E8%A1%8C%E4%BB%80%E4%B9%88%E6%93%8D%E4%BD%9C%E3%80%82
https://cloud.tencent.com/document/product/302/12647
http://c.biancheng.net/view/6457.html
https://www.cnblogs.com/cobbliu/p/3188632.html
https://www.myfreax.com/how-to-clear-the-dns-cache/
https://www.jianshu.com/p/476a92a39b45
https://tldp.org/LDP/solrhe/Securing-Optimizing-Linux-RH-Edition-v1.3/chap9sec95.html
https://zhuanlan.zhihu.com/p/101275725#:~:text=%E4%B9%9F%E5%B0%B1%E6%98%AFDNS%E6%9C%8D%E5%8A%A1%E5%99%A8%E5%9C%B0%E5%9D%80,%E5%AE%9A%E5%9C%A8lo%E8%AE%BE%E5%A4%87%E4%B8%8A%E3%80%82
http://c.biancheng.net/view/6457.html