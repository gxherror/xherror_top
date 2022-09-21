---
title: "nmap使用"
description: 转载
date: 2022-07-07T23:18:45Z
image: 
math: 
license: 
hidden: false
comments: true
draft: false
categories: LINUX
tags:
---

## 基本功能
- 端口扫描
- 主机探测：Nmap可査找目标网络中的在线主机。默认情况下，Nmap通过4种方式—— ICMP echo请求（ping）[8:0->0:0]、向443端口发送TCP	SYN	包、向80端口发送TCP ACK包和ICMP 时间戳请求[13:0->14:0]——发现目标主机。
- 服务/版本检测：在发现开放端口后，Nmap可进一步检查目标主机的检测服务协议、应用 程序名称、版本号等信息。
- 操作系统检测：Nmap	向远程主机发送一系列数据包，并能够将远程主机的响应与操作系统指纹数据库进行比较。如果发现了匹配结果，它就会显示匹配的操作系统。
- 网络路由跟踪：它通过多种协议访问目标主机的不同端口，以尽可能访问目标主机。Nmap 路由跟踪功能从TTL的高值开始测试，逐步递减TTL，直到它到零为止。
- Nmap脚本引擎：这个功能扩充了Nmap的用途。如果您要使用Nmap实现它（在默认情况下）没有的检测功能，可利用它的脚本引擎手写一个检测脚本。目前，Nmap可检査网络服务的漏洞，还可以枚举目标系统的资源。
## 端口状态
- 开放(OPEN)：工作于开放端口的服务器端的应用程序可以受理TCP	连接、接收UDP数据包或者响 应SCTP（流控制传输协议）请求。

- 关闭(CLOSED)：虽然我们确实可以访问有关的端口，但是没有应用程序工作于该端口上。

- 过滤(FILTERED)：Nmap	不能确定该端口是否开放。包过滤设备屏蔽了我们向目标发送的探测包。

- 未过滤(UNFILTERED)：虽然可以访问到指定端口，但Nmap不能确定该端口是否处于开放状态。 

- 打开｜过滤：Nmap认为指定端口处于开放状态**或**过滤状态，但是不能确定处于两者之中的哪种状态。在遇到没有响应的开放端口时，Nmap会作出这种判断。这可以是由于防火墙丢弃数据包造成的。

- 关闭｜过滤：Nmap认为指定端口处于关闭状态**或**过滤状态，但是不能确定处于两者之中的 哪种状态。
## 端口扫描原理
- TCP SYN scanning(-sS)

TCP SYN scanning 是Nmap默认的扫描方式，称作半开放扫描。

原理：该方式发送SYN到目标端口。

如果收到SYN/ACK回复，那么判断该端口是开放；
如果收到RST包，那么判断该端口是关闭；
如果没收到回复，那么判断该端口是被屏蔽。
- TCP connect scanning(-sT)

原理：TCP connect 方式使用系统网络API connect 向目标主机的端口发起TCP三次握手连接。

如果无法连接，说明该端口关闭。
优缺点：该方式扫描速度比较慢，而且由于建立完整的TCP连接会在目标机上留下记录信息，不够隐蔽。所以，TCP connect是TCP SYN无法使用才考虑选择的方式。

- TCP ACK scanning(-sA)

原理：向目标主机的端口发送ACK包。

如果收到RST包，说明该端口没有被防火墙屏蔽；
没有收到RST包，说明被屏蔽。
优缺点：该方式只能用于确定防火墙是否屏蔽某个端口，可以辅助TCP SYN的方式来判断目标主机防火墙的状况。

- TCP FIN/Xmas/NULL scanning(-sN/sF/sX)

这三种扫描方式被称为秘密扫描（Stealthy Scan）

原理：FIN扫描向目标主机的端口发送的TCP FIN包或Xmas tree包/Null包

如果收到对方RST回复包，那么说明该端口是关闭的；
没有收到RST包说明端口可能是开放的或被屏蔽的（open|filtered）。
其中Xmas tree包是指flags中FIN URG PUSH被置为1的TCP包；NULL包是指所有flags都为0的TCP包。

- UDP scanning(-sU)

UDP扫描方式用于判断UDP端口的情况。

原理：向目标主机的UDP端口发送探测包。

如果收到回复“ICMP port unreachable”就说明该端口是关闭的；
如果没有收到回复，那说明UDP端口可能是开放的或屏蔽的。

- TCP Maimon扫描（-sM）

Uriel Maimon 首先发现了TCP Maimom扫描方式。这种模式的 探测数据包含有FIN/ACK标识。对于BSD衍生出来的各种操作系统来说，如果被测端口处于 开放状态，主机将会丢弃这种探测数据包；如果被测端口处于关闭状态，那么主机将会回复 RST。

- TCPACK扫描（-sA）

这种扫描模式可以检测目标系统是否采用了数据包状态监测技术 （stateful）防火墙，并能确定哪些端口被防火墙屏蔽。这种类型的数据包只有一个ACK标识 位。如果目标主机的回复中含有RST标识，则说明目标主机没有被过滤。

- TCP窗口扫描（-sW）

这种扫描方式检测目标返回的RST数据包的TCP窗口字段。如果目 标端口处于开放状态，这个字段的值将是正值；否则它的值应当是0。

- TCP Idle扫描（-sI）

采用这种技术后，您将通过指定的僵尸主机发送扫描数据包。本机 并不与目标主机直接通信。如果对方网络里有IDS，IDS将认为发起扫描的主机是僵尸主机。
```
SCAN TECHNIQUES:
  -sS/sT/sA/sW/sM: TCP SYN/Connect()/ACK/Window/Maimon scans
  -sU: UDP Scan
  -sN/sF/sX: TCP Null, FIN, and Xmas scans
  --scanflags <flags>: Customize TCP scan flags
  -sI <zombie host[:probeport]>: Idle scan
  -sY/sZ: SCTP INIT/COOKIE-ECHO scans
  -sO: IP protocol scan
  -b <FTP relay host>: FTP bounce scan
```
## Options
```bash
-F: Fast mode - Scan fewer ports than the default scan
-T<0-5>: Set timing template (higher is faster)
-Pn: Treat all hosts as online -- skip host discovery
-sV: Probe open ports to determine service/version info
-O: Enable OS detection
OUTPUT:
-v: Increase verbosity level (use -vv or more for greater effect)
-d: Increase debugging level (use -dd or more for greater effect)
MISC:
-A: Enable OS detection, version detection, script scanning, and traceroute
```

## UDP扫描选项
Nmap有多种TCP扫描方式，而UDP扫描仅有一种扫描方式（-sU）。虽然UDP扫描结果没有 TCP扫描结果的可靠度高，但渗透测试人员不能因此而轻视UDP扫描，毕竟UDP端口代表着 可能会有价值的服务端程序。但是UDP扫描的最大问题是性能问题。由干Linux内核限制1秒内最多发送一次ICMP Port Unreachable信息。按照这个速度，对一台主机的65536个UDP端口进行完整扫描，总耗时必 定会超过18个小时。

优化方法主要是：
1. 进行并发的UDP扫描；
2. 优先扫描常用端口；
3. 在防火墙后面扫描；
4. 启用--host-timeout选项以跳过响应过慢的主机。

假如我们需要找到目标主机开放了哪些 UDP端口。为提高扫描速度，我们仅扫描 53端口 （DNS）和161端口（SNMP）。
`nmap -sU 192.168.56.103 -p 53,161`
## 参考

https://crayon-xin.github.io/2018/08/12/nmap%E8%B6%85%E8%AF%A6%E7%BB%86%E4%BD%BF%E7%94%A8%E6%8C%87%E5%8D%97/

https://www.jianshu.com/p/5b5d42eaf8a3

https://linux.die.net/man/1/nmap