---
title: "SSL/TLS"
description: 
date: 2022-07-11T13:55:37Z
image: 
math: 
license: 
hidden: false
comments: true
draft: false
categories:
    - NET
    - SEC
tags: 
---
## 历史
![28654897c0ff86fd34de0fffa8c24e05.png](../_resources/28654897c0ff86fd34de0fffa8c24e05.png)
![dbc67a9205ee82f9c7e5ef4b361009b0.png](../_resources/dbc67a9205ee82f9c7e5ef4b361009b0.png)

## 在TCP/IP模型中位置
![797ee910a822796692f407e52304649c.png](../_resources/797ee910a822796692f407e52304649c.png)
## 特点
1. SSL/TLS由于使用了加密算法，非常消耗CPU资源，因此应该尽可能将SSL在LB（负载均衡，Load Balance）层终结掉。终结的意思是负载均衡器对外提供SSL连接，对内提供TCP连接，把SSL剥离掉。这样传输更快，且后端服务不需要消耗CPU资源处理SSL了（后端服务一般都是VPC的，肯定安全）。常见的开源负载均衡器HAProxy、开源反向代理Nginx、收费负载均衡器AWS ELB等都是可以终结的。

## TLS协议的架构
![0444faa721be0a84ddfdce813a49ca5e.png](../_resources/0444faa721be0a84ddfdce813a49ca5e.png)

### 握手协议
![2c917f7d7e89689cecb8a5db99ce1343.png](../_resources/2c917f7d7e89689cecb8a5db99ce1343.png)
- ClientKeyExchange
分两种情况：
	- 如果是公钥或者RSA模式情况下，客户端将根据客户端生成的随机数和服务器端生成的随机数，生成
	**预备主密码**，通过该**公钥进行加密**，返送给服务器端。

	- 如果使用的是Diff-Hellman密钥交换协议，则客户端会发送自己这一方要生成Diff-Hellman密钥而需要公开的值。具体内容可以参考更加安全的密钥生成方法Diffie-Hellman，这样服务器端可以根据这个公开值计算出预备主密码。
- 一个加密套件包括四个部分(SSL_RSA_WITH_RC4_128_SHA)：
	- Is Exportable：是否可以导出
	- Key Exchange：密钥交换算法。用于密钥协商。
	- Cipher：对称加密算法。用于信息加密。
	- Hash：MAC的计算方法。用于完整性检验。
- 握手协议最后将计算全部的握手信息的MAC，当MAC不相等时将会直接结束会话
- 主密码和预备主密码
	- 上面的步骤8生成了预备主密码，主密码是根据密码套件中定义的单向散列函数实现的伪随机数生成器+预备主密码+客户端随机数+服务器端随机数生成的。
	- 主密码主要用来生成称密码的密钥，消息认证码的密钥和对称密码的CBC模式所使用的初始化向量。详见分组密码和模式
```
Byte   0       = SSL record type = 22 (SSL3_RT_HANDSHAKE)
Bytes 1-2      = SSL version (major/minor)
Bytes 3-4      = Length of data in the record (excluding the header itself).
Byte   5       = Handshake type
Bytes 6-8      = Length of data to follow in this record
Bytes 9-n      = Command-specific data                   
```
```
      struct {
          HandshakeType msg_type;    /* handshake type */
          uint24 length;             /* bytes in message */
          select (HandshakeType) {
              case hello_request:       HelloRequest;
              case client_hello:        ClientHello;
              case server_hello:        ServerHello;
              case certificate:         Certificate;
              case server_key_exchange: ServerKeyExchange;
              case certificate_request: CertificateRequest;
              case server_hello_done:   ServerHelloDone;
              case certificate_verify:  CertificateVerify;
              case client_key_exchange: ClientKeyExchange;
              case finished:            Finished;
          } body;
      } Handshake;

```
### TLS记录协议
![e6041ffb14b1ab6b11f98f97ef1db378.png](../_resources/e6041ffb14b1ab6b11f98f97ef1db378.png)

![c97a3f5c3ac0d890dc62553f3e4761e3.png](../_resources/c97a3f5c3ac0d890dc62553f3e4761e3.png)
```
Byte   0       = SSL record type
Bytes 1-2      = SSL version (major/minor)
Bytes 3-4      = Length of data in the record (excluding the header itself).
                 The maximum SSL supports is 16384 (16K).
```
```
SSL3_RT_CHANGE_CIPHER_SPEC      20   (x'14')
SSL3_RT_ALERT                   21   (x'15')
SSL3_RT_HANDSHAKE               22   (x'16')
SSL3_RT_APPLICATION_DATA        23   (x'17')
TLS1_RT_HEARTBEAT               24   (x'18')
```
```
TLS1_VERSION           x'0301'
TLS1_1_VERSION         x'0302'
TLS1_2_VERSION         x'0303'
```
## 参考
https://zhuanlan.zhihu.com/p/133375078

http://www.bewindoweb.com/271.html

http://www.ruanyifeng.com/blog/2014/02/ssl_tls.html

https://www.ibm.com/docs/en/ztpf/1.1.0.15?topic=sessions-ssl-record-format

https://datatracker.ietf.org/doc/html/rfc5246#section-7.3

https://www.researchgate.net/figure/The-TLS-layers-and-sub-protocols_fig4_321347130
