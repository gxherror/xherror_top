---
title: "ISA-RISC-V实现"
description: 学习
date: 2023-01-02T15:05:15Z
image: 
math: 
license: 
hidden: false
comments: true
categories:
    - SS
tags:
---
## 指令集简介

<img src="/images/image-20221222215941112.png" alt="image-20221222215941112" style="zoom:80%;" />

## 寄存器

Saver保障执行前后R中的值不变->被调用函数(s0-11)压栈保存

![image-20221026194247271](/images/image-20221026194247271.png)



## 指令编码

- **imm用补码表示**

### 概览

![image-20221222234637037](/images/image-20221222234637037.png)

![image-20221019192241813](/images/image-20221019192241813.png)

http://riscvbook.com/chinese/RISC-V-Reader-Chinese-v2p1.pdf

https://venus.cs61c.org/

-  R类型指令: 寄存器-寄存器 算术/逻辑运算
-  I类型指令: 寄存器-立即数 算术/逻辑运算 和所有load指令、ecall , Jalr,注意:**imm只有12位,补码表示( -2048 ~ +2047)**
   -  I型imm带符号扩展到32位

-  S类型指令: 所有store指令
   -  为保持源寄存器的编码与R型保持一致,分割imm

-  SB类型指令: 所有branch指令
   - 12位立即数表示的偏移量为：（ -4096 ~ +4094） * 2 byte,**注意一条指令长默认为4B**
   - ![image-20221102192908110](/images/image-20221102192908110.png)
-  U类型指令: 立即数加载至高20位（ 20-bit upper immediate ）指令
-  J类型指令: jump指令
   - PC=PC+Offset (±1MB 范围， 即：immediate（ -2^19 ~ 2^19 ）* 2 bytes)

### 算术运算

![image-20221019192335619](/images/image-20221019192335619.png)

![image-20221019192427099](/images/image-20221019192427099.png)

### 逻辑运算

**按位取与/或/非**

![image-20221019192900844](/images/image-20221019192900844.png)

![image-20221019192828932](/images/image-20221019192828932.png)

### 传送指令

rd寄存器用于WB写回阶段,这里用rs2

![image-20221019195624595](/images/image-20221019195624595.png)

#### lb(load byte)

<img src="/images/image-20221222222347137.png" alt="image-20221222222347137" style="zoom:50%;" />

### 控制流指令

![image-20221222223141060](/images/image-20221222223141060.png)

注意`jal SUM`默认`rd`为`ra`用于调用,而`jal x0 LOOP`用于LOOP跳转

`jal`相对寻址

如果跳转目标离当前指令的2^20> 距离 > 2^10条指令(假设指令长4B)

![image-20221223003518771](/images/image-20221223003518771.png)

![image-20221102191158411](/images/image-20221102191158411.png)

### U格式指令

![image-20221102193319073](/images/image-20221102193319073.png)

LUI 将立即数设置在目标寄存器的高20位,低12位填0,与ADDI指令一起,设置一个32位立即数

<img src="/images/image-20221222232630046.png" alt="image-20221222232630046" style="zoom:50%;" />

### 伪指令

- `jr ra`:`jalr`变体
- `mv dst reg1`:`addi dst reg1 ,x0`
- `li dst imm`:转成`addi`与`lui(load upper imm)`
- `la dst label`:`auipc(add upper imm to PC) dst <offset to label>` 

<img src="/images/image-20221222232857979.png" alt="image-20221222232857979" style="zoom: 67%;" />

## 函数的调用与返回

<img src="/images/image-20221222224745368.png" alt="image-20221222224745368" style="zoom:67%;" />

- 主程序将参数放置在函数可以访问到的位置 ：`a0–a7 (x10-x17)`:八个参数寄存器

- 函数调用 `jal Procedure Address`：将下一条指令的地址,保存在寄存器 `$ra`，跳转到PA
- 被调用的函数将执行结果存放在主程序可以访问的位置 ：`a0-a1`: 两个结果值寄存器
- 函数返回 `jr $ra`：跳转到寄存器 `$ra` 中记录的地址处取指令执行
- 注意！超出限定数量的参数、返回地址通过**栈**来传递

递归阶乘函数的调用过程:

<img src="/images/image-20221222231420139.png" alt="image-20221222231420139" style="zoom:67%;" />

## 练习

1.寄存器中的值有时是地址，有时是数据，在指令中，它们在形式上没有差别，只有通过（  ）才能识别它是数据还是地址。

A.时序信号

B.指令操作码或寻址方式位  

C.寄存器编号    

D.判断程序 