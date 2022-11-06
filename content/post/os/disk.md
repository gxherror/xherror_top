---
title: "磁盘管理"
description: 学习
date: 2022-10-28T16:38:32Z
image: 
math: 
license: 
hidden: false
comments: true
categories:
    - OS
tags:
---
## 物理结构

![23e3098a40c4d6c69b7f955e118b6446.png](/images/23e3098a40c4d6c69b7f955e118b6446.png)

- 磁盘的最小单位是扇区（sector），每个**sector 512 B**，是磁盘原子操作的单位

- 磁道偏斜（track skew）:抵消seek time与rotate time
- 后写（write back）缓存/（立即报告，immediate reporting）与直写（write through）
- 平均磁盘寻道时间大约为完整寻道时间的三分之一
  - ![image-20221026231538358](/images/image-20221026231538358.png)- >![image-20221026231615942](/images/image-20221026231615942.png)

## 磁盘驱动器(disk drive)

![image-20221026231354192](/images/image-20221026231354192.png)

## 磁头调度

- I/O 合并（I/O merging）,合并相邻块I/O请求
- 工作保全（work-conserving）



- SSTF/NBF：Shortest-Seek-Time-First,Nearest-Block-First
  - 饥饿（starvation）,忽略了旋转
- 电梯（elevator）算法
  - SCAN
  - F-SCAN
  - C-SCAN
- SPTF:Shortest Positioning Time First
  - 通常在驱动器内部执行

## RAID,Redundant Array of Inexpensive Disks

![7791510bf758f708f64f3ac1221b3a7f.png](/images/7791510bf758f708f64f3ac1221b3a7f.png)

- striping

  - Bit-level striping 

  - Block-level striping

- parity
  - Parity block j stores XOR of bits from block j  of each disk
  - XOR(0,0,1,1)=0
  - 加法奇偶校验（additive parity）
  - 减法奇偶校验（subtractive parity）![image-20221026233742809](/images/image-20221026233742809.png)
  - 奇偶校验的 RAID 的小写入问题（small-write problem）:即使可以并行访问数据磁盘，奇偶校验磁盘也不会实现任何并行
  - 写时需要两次I/O,先读再写

![image-20221026235304847](/images/image-20221026235304847.png)

![image-20221026234236483](/images/image-20221026234236483.png)



## 磁盘故障

提供数据完整性（data integrity）或数据保护（data protection）

利用磁盘擦净（disk scrubbing）定期读取系统的每个块，并检查校验和是否仍然有效来减少某个数据项的所
有副本都被破坏的可能性

- 故障—停止（fail-stop）
- 故障—部分（fail-partial）
  - 潜在扇区错误（Latent-Sector Errors，LSE）
    - 通过纠错码（Error Correcting Code，ECC）重建（reconstruct）磁盘
  - 块讹误（block corruption）
    - 磁盘本身无法检测到：通过有故障的总线从主机传输到磁盘
    - 块的校验和（checksum）：XOR，CRC，Fletcher checksum
  - 错误位置的写入（misdirected write）
    - 在校验和中添加物理标识符（Physical Identifier，物理 ID），识别disk与block
  - 丢失的写入（lost write）
    - 设备通知上层写入已完成，但事实上它从未持久
    - 写入后读取（read-after-write）
    - inode中添加文件中每个块的校验和（同时丢失对 inode和数据的写入时失效）

### Fletcher checksum



- CB0 = 255 − ((C0 + C1) mod 255)
- CB1 = 255 − ((C0 + CB0) mod 255)

|  Byte (B)  | C0 = (C0prev + B) mod 255 | C1 = (C1prev + C0) mod 255 |    Description     |
| :--------: | :-----------------------: | :------------------------: | :----------------: |
|    0x01    |           0x01            |            0x01            | First byte fed in  |
|    0x02    |           0x03            |            0x04            | Second byte fed in |
| CB0 = 0xF8 |           0xFB            |            0x00            |  Checksum  byte 1  |
| CB1 = 0x04 |           0x00            |            0x00            |  Checksum byte 2   |



https://www.cs.auckland.ac.nz/courses/compsci314s1c/lectures/Checksums.pdf

https://seniordba.wordpress.com/2019/01/14/raid-levels-explained-2/