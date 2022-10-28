---
title: "页与页表"
description: 学习
date: 2022-10-28T15:50:29Z
image: 
math: 
license: 
hidden: false
comments: true
categories:
    - OS
tags:
---
# 分页

- 用户程序映射与OS特权程序映射
- 地址空间中的虚拟页（virtual page）与 物理内存中的物理帧（physical frame）
- 请求分页时的惰性（lazy）优化：按需置零（demand zeroing），写时复制（copy-on-write，COW）
- 页表（page table）进行地址转换（address translation），实现VPN ->PFN映射 

![image-20221025164352644](/images/image-20221025164352644.png)


- 页表格条目（PTE）存在位（P），读/写位（R/W） ，用户/超级用户位（U/S），有几位（PWT、PCD、PAT 和 G）确定硬件缓存如何为这些页面工作，一个访问位（A）有时用于追踪页是否被访问，也用于确定哪些页很受欢迎和一个脏位（D），最后是页帧号（PFN）

![image-20221025164846328](/images/image-20221025164846328.png)


- 页表是一个每进程的数据结构
- 页表基址寄存器（page-table base register，PTBR）包含页表的起始位置的物理地址

## 内存追踪案例

```c
for (i = 0; i < 1000; i++)
    array[i] = 0;
```

```assembly
0x1024 movl $0x0,(%edi,%eax,4)
0x1028 incl %eax
0x102c cmpl $0x03e8,%eax
0x1030 jne
0x1024
```

- 每一次循环包括
  - 4 x 每个获取指令产生两个内存引用：一个访问页表以查找指令所在的物理框架，另一个访问指令本身将其提取到 CPU 进行处理
  - 1 x 显式的内存引用，这会首先增加另一个页表访问获得数组所在的物理地址，然后访问数组本身

![image-20221025170757409](/images/image-20221025170757409.png)


## TLB

- 地址转换旁路缓冲存储器（translation-lookasidebuffer，TLB），它就是频繁发生的虚拟到物理地址转换的硬件缓存（cache）
- 当OS特权程序也进行映射时，应避免TLB 未命中的无限递归，预留TLB项
- 多级TLB
- 一条地址映射可能出现在任意位置（用硬件的术语， TLB 被称为全相联的（fully-associative）缓存）
- 替换策略：最近最少使用（least-recently-used， LRU）/RANDOM/ETC
- 一个程序超出TLB 覆盖范围（TLB coverage）
- 访问 TLB 很容易成为 CPU 流水线的瓶颈
  - 物理地址索引缓存（physically-indexed cache）

```c
VPN = (VirtualAddress & VPN_MASK) >> SHIFT
(Success, TlbEntry) = TLB_Lookup(VPN)
if (Success == True)
    // TLB Hit
    if (CanAccess(TlbEntry.ProtectBits) == True)
        Offset = VirtualAddress & OFFSET_MASK
        PhysAddr = (TlbEntry.PFN << SHIFT) | Offset
        Register = AccessMemory(PhysAddr)
    else
    RaiseException(PROTECTION_FAULT)
else
    // TLB Miss
    // first, get page directory entry
    PDIndex = (VPN & PD_MASK) >> PD_SHIFT
    PDEAddr = PDBR + (PDIndex * sizeof(PDE))
    PDE = AccessMemory(PDEAddr)
    if (PDE.Valid == False)
        RaiseException(SEGMENTATION_FAULT)
    else
        // PDE is valid: now fetch PTE from page table
        PTIndex = (VPN & PT_MASK) >> PT_SHIFT
        PTEAddr = (PDE.PFN << SHIFT) + (PTIndex * sizeof(PTE))
        PTE = AccessMemory(PTEAddr)
    if (PTE.Valid == False)
        RaiseException(SEGMENTATION_FAULT)
    else if (CanAccess(PTE.ProtectBits) == False)
        RaiseException(PROTECTION_FAULT)
    else if (PTE.Present == True)
		 // assuming hardware-managed TLB
		TLB_Insert(VPN, PTE.PFN, PTE.ProtectBits)
		RetryInstruction()
	else if (PTE.Present == False)
		RaiseException(PAGE_FAULT)
```

### TLB项

- 上下文切换改变页表基址寄存器（PTBR），设置（Address Space Identifier，ASID）
  - 正在运行的进程数超过 256个怎么办
- 不同VPN映射相同PFN，实现多进程共享同一物理页
- MIPS R4000支持32位地址空间，页大小为 4KB，一半预留给OS，对应VPN为19位
- PFN对应支持最多有 64GB 物理内存

![image-20221025171452224](/images/image-20221025171452224.png)


![image-20221025181308610](/images/image-20221025181308610.png)


### 实践

测算TLB 的容量和访问 TLB 的开销

## 较小的表

一个 32 位地址空间，4KB的页，将会有20位VPN，假设 4 字节的PTE，每个程序将会有一个4MB的页表

- 更大的页
- 分页+分段
  - 不是为进程的整个地址空间提供单个**页表**，而是为每个逻辑分段（代码、堆和栈部分）提供一个页表。
  - ![image-20221025193550187](/images/image-20221025193550187.png)
- 交换（swap）到磁盘

### 多级页表

- 去掉页表中的所有无效区域，对页表继续分页
- 添加页目录（page directory，PD），由多个页目录项（Page Directory Entries， PDE）组成

![image-20221025193916860](/images/image-20221025193916860.png)


- PDEAddr = PageDirBase +（PDIndex × sizeof（PDE））
- PTEAddr = (PDE.PFN << SHIFT) + (PTIndex * sizeof(PTE))

![image-20221025195103609](/images/image-20221025195103609.png)


### HASH反向页表（hashed inverted page table）

- 极端的空间节省，一定程度的搜索时间上升
- 适合用于VPN大，PFN小的情况
- Since collisions may occur, the hashed inverted page table must do chaining
- Assuming a good hash function, the average chain length should be about 1.5, so only 2.5 memory accesses are required on average to translate an address . This is pretty good, considering a two-level page table requires 2 accesses

![image-20221026161235606](/images/image-20221026161235606.png)


### 内核虚拟内存中放置用户页表

- 如果内存受到严重压力，内核可以将这些页表的页面交换到磁盘，从而使物理内存可以用于其他用途
- 转换 P0 或 P1 中的虚拟地址，首先需要先**查阅系统页表 -> 获得用户页表的物理地址**，再进行页表查询





http://web.eecs.umich.edu/~akamil/teaching/sp04/040104.pdf