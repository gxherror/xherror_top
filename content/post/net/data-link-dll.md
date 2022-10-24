---
title: "数据链路层DLL"
description: 学习
date: 2022-10-24T14:41:33Z
image: 
math: 
license: 
hidden: false
comments: true
categories:
    - NET
tags:
---
## 服务与功能

- 无确认 无连接 服务（ Unacknowledged connectionless ）
  - Ethernet
- 有确认 无连接 服务（ Acknowledged connectionless ）
  - IEEE802.11
- 广播信道
  - 要求MAC地址
  - Ethernet,IEEE802.11

- 单播信道
  - PPP

- 成帧 （Framing）
- 差错控制 （Error Control）
- 流量控制 （Flow Control）

## 成帧

- 字节计数法
- 字节定界符
- 比特定界符
- 4B/5B编码
- 前导码(preamble)
- 曼切斯特编码

## 差错控制 

- 错误（ incorrect ）：数据发生错误 
- 丢失（ lost ）：接收方未收到 
- 乱序（out of order）：先发后到，后发先到 
- 重复（repeatedly delivery）：一次发送，多次接收

### EDC

- parity check

![image-20221021102615695](/images/image-20221021102615695.png)
![image-20221021102615695](/images/image-20221021102615695.png)

- checksumming method

![image-20221021103324779](/images/image-20221021103324779.png)
![image-20221021103324779](/images/image-20221021103324779.png)

- CRC(cyclic redundancy check)
  - G最高位1,通常取32位
  - **模2除法==XOR**
  - error<n+1可被检测,error>=n+1有概率被检测

![image-20221021104404628](/images/image-20221021104404628.png)![image-20221021104410788](../../_resources/image-20221021104410788.png)
![image-20221021104404628](/images/image-20221021104404628.png)![image-20221021104410788](../../_resources/image-20221021104410788.png)

### ECC

![image-20221021105515014](/images/image-20221021105515014.png)
![image-20221021105515014](/images/image-20221021105515014.png)

- 海明码

  - 基于偶校验,提供一位的校验能力
  - 校验位(1,2,4,8)为出错位数的二进制表示
  - 可采用k个码字（n = m + r）组成 k x n 矩阵，按列发送，可纠正最多为k个的突发性连续比特错

  ![image-20221021105637530](/images/image-20221021105637530.png)
  ![image-20221021105637530](/images/image-20221021105637530.png)

  

## PPP

- PPP被用在许多类型的物理网络中，包括电话线、移动电话等
- PPP还用在互联网接入上。早年，ISP使用PPP为用户提供Dial up，两个派生物PPPoE和PPPoA被ISP广泛用来与用户创建DSL与FTTH
- 链路控制协议 LCP (Link Control Protocol)。
  -  用来建立、配置和测试数据链路的链路控制协议，通信双方可协商一些选项

- 网络控制协议 NCP (Network Control Protocol)。
  -  其中每个协议支持一种不同的网络层协议，如IP、OSI的网络层、DECnet、
     AppleTalk等


![image-20221022160508878](/images/image-20221022160508878.png)
![image-20221022160508878](/images/image-20221022160508878.png)

![image-20221022161107254](/images/image-20221022161107254.png)
![image-20221022161107254](/images/image-20221022161107254.png)

### PPPoE（PPP over Ethernet）

- 提供在以太网链路上的PPP连接
- 实现了传统以太网不能提供的身份验证、加密，以及压缩等功能
- 实现基于用户的访问控制、计费、业务类型分类等，运营商广泛支持
- PPPoE使用Client/Server模型，服务器通常是接入服务器

![image-20221022161508069](/images/image-20221022161508069.png)
![image-20221022161508069](/images/image-20221022161508069.png)

![image-20221022161739014](/images/image-20221022161739014.png)
![image-20221022161739014](/images/image-20221022161739014.png)
