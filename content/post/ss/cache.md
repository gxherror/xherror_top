---
title: "高速缓存"
description: 学习 
date: 2023-01-02T15:11:30Z
image: 
math: 
license: 
hidden: false
comments: true
categories:
    - SS
tags:
---
## 概括

- 如何判断一个数据在cache中 
  - 数据查找Data Identification 
- 如需访问的数据在cache中，存放在什么地方
  - 地址映射Address Mapping 
- Cache满了以后如何处理 
  - 替换策略Placement Policy 
- 如何保证cache与memory的一致性 
  - 写入策略Write Policy

![cab13e17a7d018ff854a7c6afe31fb33.png](/images/cab13e17a7d018ff854a7c6afe31fb33.png)

## address map

高速缓存（cache）与主存的地址映射是由硬件自动完成的

- 直接(direct mapped) 
  - ![b5e8ad14c323c67fcf6b61c7d9690e6](/images/b5e8ad14c323c67fcf6b61c7d9690e6.jpg)
  - 查找速度快，命中率相对前者稍低,适合大容量Cache
  - ping-pong效应
- 全相联(fully-associated),即对页面可以放置的内存位置没有限制
  - ![image-20221223180434435](/images/image-20221223180434435.png)
- 相联(set-associated)
  - ![c38b7d85b76c1e4dd1bc0e2350e9b087.png](/images/c38b7d85b76c1e4dd1bc0e2350e9b087.png)
  - Direct-Mapped Caches ,A cache with exactly one line per set (E = 1)
  - Fully-Associated CAches,S = 1 set
  - set index in middle 

<img src="/images/image-20221224163954554.png" alt="image-20221224163954554" style="zoom:50%;" />

## cache miss

- cold(compulsory) miss
- conflict miss
  - 由集合关联性（set-associativity）引起
- capacity misses
- ![b9ea6deb9abf5d32830ba1495a6f3776.png](/images/b9ea6deb9abf5d32830ba1495a6f3776.png)

### GEMM

![image-20221224225206621](/images/image-20221224225206621.png)

```
/* B x B mini matrix multiplications */
for (i1 = i; i1 < i+B; i++)
    for (j1 = j; j1 < j+B; j++)
        for (k1 = k; k1 < k+B; k++)
        c[i1*n+j1] += a[i1*n + k1]*b[k1*n + j1];
```

![image-20221224225009201](/images/image-20221224225009201.png)

- 分块确保每次取的cache被充分使用，不发生颠簸
- 每次（分块）迭代的失效数：2n/B * B^2/8 = nB/4
- 总共的错失数：nB/4 * (n/B)^2 = n^3 /(4B)
- 可能大的分块大小 B, 但限制 3B^2 < C

## Write Policy

- Cache hit
  - write through:写入cache,同时写入mem
  - write back:只写回cache,当发生替代时再写回mem
- Cache miss
  - write allocate:将block调入cache再写
  - no write allocate:直接写mem

## Placement Policy 

- LRU
  - 每次访问更新关联set内每一line的排序
  - ![image-20221224224452885](/images/image-20221224224452885.png)
- 近似LRU
  - 添加脏位
- LFU
- Random
  - 对特殊情况的处理比较良好

## ☆一致性

### VI

- 在多个私有高速缓存中，最多只能有一个拥有数据块的最新拷贝，即使是只用于读的拷贝,这会影响共享的只读数据结构（如指令）的访问性能

![image-20221224225957861](/images/image-20221224225957861.png)

![image-20221224225821932](/images/image-20221224225821932.png)

### MSI

![56cb06d2ee4c27bfe9914aee908d02b](/images/56cb06d2ee4c27bfe9914aee908d02b.jpg)

![image-20221224230807453](/images/image-20221224230807453.png)

#### 假共享问题

P1和P2的动作是串行的，出现乒乓现象，还增加了数据块在不同处理器之间来回传送的开销

```
如下代码在SMP（shared memory multiprocessors）环境下执行，sum和sum_local是全局变量，被NUM_THREADS个线程所共享：
    
double sum=0.0, sum_local[NUM_THREADS];
#pragma omp(openmp) parallel num_threads(NUM_THREADS)
//由NUM_THREADS个线程执行以下相同的代码段
{ 
    int me = omp_get_thread_num();
    sum_local[me] = 0.0;
    #pragma omp for //并行for语句，不同线程处理部分数据
    for (i = 0; i < N; i++)
        sum_local[me] += x[i] * y[i]; //将结果存入对应该线程的sum_local元素中
    #pragma omp atomic
    //并行原子操作，
    sum += sum_local[me]; //求总和
}
```



### other

![image-20221224231013035](/images/image-20221224231013035.png)



## 题

1.存储容量为16K*4的DRAM芯片，其地址引脚和数据引脚各是

2.假定采用多模块交叉存储器组织方式，存储器芯片和总线支持突发传送（burst)，CPU通过存储器总线读取数据的过程为：发送首地址和读命令需1个时钟周期，存储器准备第一个数据需8个时钟周期(即CAS潜伏期=8)，随后每个时钟周期总线上传送1个数据，可连续传送8个数据(即突发长度=8)。若主存和cache之间交换的主存块大小为64B，存储宽度和总线宽度都为8B，则cache的一次缺失损失（缺失开销）至少为（17）个时钟周期。

3.‌假定CPU通过存储器总线读取数据的过程为：发送地址和读命令需1个时钟周期，存储器准备一个数据需8个时钟周期，总线上每传送1个数据需1个时钟周期，若主存和cache之间交换的主存块大小为64B，存取宽度和总线宽度都为8B，则cache的一次缺失损失（缺失开销）至少为（ 80）个时钟周期。

4.缓存到地址映射中__全相联映射___比较多的采用“按内容寻址”的相联存储器来实现 

‌‍