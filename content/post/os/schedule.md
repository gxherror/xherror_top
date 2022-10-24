---
title: "进程调度"
description: 学习
date: 2022-10-24T14:50:14Z
image: 
math: 
license: 
hidden: false
comments: true
categories:
 - OS
tags:
---
- method
  - 周转时间（turnaround time）:T 周转时间 = T 完成时间 −T 到达时间
  - 响应时间（response time）:T 响应时间 = T 首次运行 −T 到达时间
- FIFO(FCFS)
- SJF(shortesrt job first)
  - 需要知道运行时间
  - non-preemptive
- STCF(PSJF)
  - 需要知道运行时间
  - preemptive
- RR
  - 公平调度
- LOTTERY
  - 比例份额(patitional-share)/公平份额(fair-share)
  - 随机选择速度快，方便实现
  - 彩票的分配？
  - ticket currency
  - ticket transfer
  - ticket inflation

- stride schedule
  - 根据彩票设置步长
  - 执行拥有最小行程的进程，保障进程进度基本相同
  - 需要维护全局状态来设置新进程的步长
- O(1)
- BFS


### MLFQ（Multi-level Feedback Queue）

- 规则 1：如果 A 的优先级 > B 的优先级，运行 A（不运行 B）。
- 规则 2：如果 A 的优先级 = B 的优先级，轮转运行 A 和 B。
- 规则 3：工作进入系统时，放在最高优先级（最上层队列）。
- 规则 4：一旦工作用完了其在某一层中的时间配额（无论中间主动放弃了多少次CPU，进入堵塞），就降低其优先级（移入低一级队列）
  - 保证交互密集型任务高优先级
  - 避免愚弄调度进程
- 规则 5：经过一段时间 S，就将系统中所有工作重新加入最高优先级队列。
  - 防止starvation

### multiprocessor schedule

- 缓存一致性（cache coherence）问题
  - 总线窥探（bus snooping）
- 缓存亲和度（cache affinity）
  - 进程保持在同一个 CPU 上



- 单队列多处理器调度（Single Queue Multiprocessor Scheduling，SQMS）
  - 缺乏可扩展性（scalability）。为了保证在多CPU 上正常运行，需要加锁（locking）
  - 缺少缓存亲和度（cache affinity）

![image-20221024202521679](/images/image-20221024202521679.png)
![image-20221024202521679](/images/image-20221024202521679.png)

- 多队列多处理器调度（Multi-Queue Multiprocessor Scheduling，MQMS）
  - 使用迁移（migration）来确保公平性

![image-20221024202534013](/images/image-20221024202534013.png)
![image-20221024202534013](/images/image-20221024202534013.png)

### CFS

![img](/images/linux-schedule-arch.png)
![img](/images/linux-schedule-arch.png)

- MQMS
- 时间复杂度O(1)，空间复杂度较高
- 随着任务的执行，它的运行时间增加，因此vruntime也会变大，它会在红黑树中向右移动
- 计算密集型作业将运行很长时间，因此它将移到最右侧
- I/O密集型作业会运行很短的时间，因此它只会稍微向右移动
- 对于更重要的任务，也就是nice值较小的（一般是小于0），他们的移动速度相对慢很多。（相对于nice = 0的任务，nice每小一级，CPU usage就会多10%，"10% effect"）虚拟时钟的滴答声更慢。



### O(1)

![img](/images/v2-729fb18fa3ac1e41beff0fcd817c92a6_720w.webp)
![img](/images/v2-729fb18fa3ac1e41beff0fcd817c92a6_720w.webp)



https://dreamgoing.github.io/linux%E8%BF%9B%E7%A8%8B%E8%B0%83%E5%BA%A6.html

https://zhuanlan.zhihu.com/p/372441187

https://zhuanlan.zhihu.com/p/33461281