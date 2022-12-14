---
title: "编码与单元测试"
description: 学习
date: 2022-12-28T15:20:25Z
image: 
math: 
license: 
hidden: false
comments: true
categories:
    - SE
tags:
---
# 编码

编码就是把软件设计结果翻译成用某种程序设计语言书写的程序,是对设计的进一步具体化。

## 语言选择

C：操作系统、嵌入式、驱动开发 
C++：图形图像、科研、通信、桌面软件、游戏、游戏服务器 
C#：Windows桌面软件、.NET Web、服务器 
Java：  Java SE：跨平台桌面应用，Android；Java EE：企业级应用，web开发、服务 
器后端；Java ME：手机应用、流行于非智能机时代；Java Android：用于安卓开发应用

GO：高性能服务器应用，比较年轻 
Erlang：高并发服务器应用，多用于游戏 
Python：Web、科学计算、运维 
Ruby：web 
Perl：运维、文本处理，用的较少 
Lisp：科研，一种逻辑语言，用于人工智能 
Node：一个JavaScript运行环境（runtime） 
Haskell：Haskell是一种标准化的、通用纯函数编程语言，数学逻辑方面 
Scala：一种类似Java的编程语言，集成面向对象编程和函数式编程的各种特性 
Javascript：前端，在node中可以做后端 
HTML/CSS：标记语言，主要是给前端工程师构建页面使用

## 排版风格

## 命名风格 

### 匈牙利命名法 

该命名法是在每个变量名的前面加上若干表示数据类型的字符。基本 原则是：变量名=属性+类型+对象描述。如i表示int，所有i开头的变量都表示int类型。

### 骆驼命名法 

正如它的名称所表示的那样，是指混合使用大小 写字母来构成变量和函数的名字。首字母为小写， 如userName。因为看上去像驼峰，因此而得名。

### 帕斯卡命名法 

即pascal命名法。做法是首字母大写，如UserName，常用在类的变量命名中。

```
#define   ARRAY_LEN 10
fun getValue()
int rectangleWidth
class Book
```

## 注释风格



# 测试

**程序的质量主要取决于软件设计的质量**。软件测试是保证软件质量的关键步骤，是对软件规格说明、设计和编码的最后复审

![691d121931e9e2d5211aea84e0b3db46.png](/images/691d121931e9e2d5211aea84e0b3db46.png)

## 概念

- 测试目标
  - 测试的正确定义是“为了发现程序中的错误而执行程序的过程”
  - 成功的测试是发现了至今为止尚未发现的错误的测试
- 测试准则
  -  所有测试都应该能追溯到用户需求
  -  应该远在测试开始之前就制定出测试计划:**总体设计时制定测试计划**
  -  把Pareto原理(8/2原则)应用到软件测试中
  -  应该从“小规模”测试开始,并逐步进行“大规模”测试
  -  穷举测试是不可能的
  -  为了达到最佳的测试效果,应该由独立的**第三方从事测试工作**
- 测试方法
  - 黑盒测试（又称功能测试）,在程序接口进行的测试
  - 白盒测试（又称结构测试）,检测程序中的主要执行通路是否都能按 预定要求正确工作

- 测试步骤
  - 四类测试+平行运行
  - <img src="/images/image-20221226213059658.png" alt="image-20221226213059658" style="zoom: 33%;" /><img src="../_resources/image-20221226213141979.png" alt="image-20221226213141979" style="zoom:50%;" />

- 测试信息流
  - ![image-20221226213327175](/images/image-20221226213327175.png)


## 单元测试

- 在模块编写完成且无编译错误即可进行
- 通常白盒子测试,多个模块的测试可以并行 地进行
- 单元测试和编码属于软件过程的同一个阶段

![image-20221104222527563](/images/image-20221104222527563.png)

![image-20221104222210398](/images/image-20221104222210398.png)

## 集成测试

- **自顶向下集成方法**是从主控制模块开始，沿着程序的控制层次向下移动， 逐渐把各个模块结合起来。在把附属于主控制模块的那些模块组装到程序结构中去时，或者使用深度优先的策略，或者使用宽度优先的策略
  - 自顶向下测试方法的主要优点是不需要测试驱动程序，能够在测试阶段的早期实现并验证系统的**主要功能**，而且能在早期发现上层模块的接口错误。 
  - 自顶向下测试方法的主要缺点是需要存根程序，可能遇到与此相联系的测试困难，**低层关键模块中的错误发现较晚**，而且用这种方法在早期不能充分展开人力。

- **自底向上测试**从“原子”模块(即在软件结构最低层的模块)开始组装和测试。因为是从底部向上结合模块，总能得到所需的下层模块处理功能， 所以不需要存根程序
- **改进的自顶向下测试方法**。基本上使用自顶向下的测试方法，但是在早期使用自底向上的方法测试软件中的少数关键模块。一般的自顶向下方法所具有的优点在这种方法中也都有，而且能在测试的早期发现关键模块中的错误；但是，它的缺点也比自顶向下方法多一条，即测试关键模块时需要驱动程序。 
- **混合法**。对软件结构中较上层使用的自顶向下方法与对软件结构中较下层使用的自底向上方法相结合。这种方法兼有两种方法的优点和缺点,当被测试的软件中关键模块比较多时，这种混合法可能是最好的折衷方法。

## 回归测试

在集成测试的范畴中，回归测试是指重新执行已经做过的测试的某个子集，以保证上述这些变化没有带来非预期的副作用

## 确认测试

确认测试也称为验收测试，它的目标是验证软件的有效性,通常是黑盒测试

- Verification(验证)：Are we building the product right？ 

- Validation(确认)： Are we building the right product？

- Alpha测试由用户在开发者的场所进行，并且在开发者对用户的“指导”下进行测试,在受控的环境中进行的
- Beta测试由软件的最终用户们在一个或多个客户场所进行。与Alpha测试不同，开发者通常不在Beta测试的现场,不能控制的环境中的“真实”应用

## 黑盒测试 

https://blog.csdn.net/weixin_36158949/article/details/79368656

动态测试，又称**功能**测试，黑盒测试是在**程序接口**进行的测试,,与白盒测试互补的测试方法,主要用于测试过程的后期,着重测试软件功能

### 错误类型

- 功能不正确或遗漏了功能；
- 界面错误；
- 数据结构错误或外部数据库访问错误；
- 性能错误；
- 初始化和终止错误。

### 等价类划分

- 有效等价类和无效等价类,一个或多个

- 设计一个新的测试方案以尽可能多地覆盖尚未被覆盖的有效等价类

- 设计一个新的测试方案使它覆盖一个而且**只覆盖一个**尚未被覆盖的无效等价类
  - 程序要求：输入三个整数a.b.c分别作为三角形的三边长度，通过程序判定所构成的三角形的类型；当三角形为一般三角形、 等腰三角形或等边三角形时，分别作  …处理

  - ![image-20221226221534217](/images/image-20221226221534217.png)

- 测试输入组合的一个有效途径是利用**判定表或判定树**为工具，列出输入数据各种组合与程序应作的动作(及相应的输出结果)之间的对应关系，然 后为判定表的每一列至少设计一个测试用例


### 边界值分析法

- 使用边界值分析方法设计测试方案首先应该确定边界情况，通常输入等价类和输出等价类的边界。选取的测试数据应该刚好等于、刚刚小于和刚刚大于边界值
- 通常设计测试方案时总是联合使用**等价划分和边界值分析**两种技术

- 三点分析法
  - 上点就是区间的端点值
  - 内点就是上点之间任意一点
  - 离点，要分具体情况，如果开区间的离点，就是开区间中上点内侧紧邻的点；如果是闭区间的离点，就是闭区间中上点外侧紧邻的点

### 错误推测法

错误推测法在很大程度上靠直觉和经验进行。它的基本想法是列举出 程序中可能有的错误和容易发生错误的特殊情况，并且根据它们选择测试 方案

## 白盒测试 

动态测试，又称**结构**测试，测试者完全知道程序的结构和处理算法，在测试过程的**早期**阶段进行

### 逻辑覆盖

#### **语句覆盖**

使得程序中的**每个可执行语句至少执行一次**,**最弱的逻辑覆盖准则**

![img](/images/20210320173305545.png)

- 一个测试用例就可以（x = 4 , y = 5 , z = 5）

- ```java
  //只需取n=2和n=-1这两个测试用例，便可以满足语句覆盖
  public int fib(int n){
      if(n == 0)
          return 0;
      if(n == 1)
          return 1;
      if(n >= 2)
          return fib(n-1) + fib(n-2);
      else
          return -1;
  }
  ```

#### **分支/判定覆盖**

<img src="/images/image-20221227002000483.png" alt="image-20221227002000483" style="zoom:50%;" />

程序中的**每个判定**至少都获得一次“真”值和“假”值,依然**不能保证判断条件完全正确**,如`y>5错写成y<5`

- ① A=3，B=0，X=3 (覆盖sacbd) ② A=2，B=1，X=1 (覆盖sabed)

#### **条件覆盖**

程序中每个判定包含的**每个条件的可能取值**（真/假）都至少满足一次

- ① A=2,B=0,X=4② A=1,B=1,X=1
- ((a || b) && (c || d)) 条件为**四个**
- 条件覆盖并**不一定**比判定覆盖强，满足条件覆盖的测试用例不一定满足判定覆盖

![image-20221106155331031](/images/image-20221106155331031.png)

只需设计如下2个测试用例即可满足100%条件覆盖,**无需考虑是否真的执行了**

![预览大图](/images/1690230.png)

#### **判定/条件覆盖**

使得**判定中每个条件**的所有可能结果至少出现一次，**每个判定**本身所有可能结果也至少出现一次

![预览大图](/images/1686157.png)



- ① A=2,B=0,X=4 ② A=1,B=1,X=1

#### **条件组合覆盖**

程序中**每个判定内**的所有可能的**条件**取值**组合**都至少出现一次，包含判定/条件覆盖,最强的逻辑覆盖标准

- ​	限于每个判定**内**
- （x>3,z<10   x<=3,z<10   x>3,z>=10   x>=3,z>=10）+（x==4,y>5  x==4,y,=5 x!=4,y>5 x!=4,y<=5）
- **满足条件组合覆盖标准的测试数据并不一定能使程序中的每条路径都执行到**

> 现有8瓶一模一样的酒，其中一瓶有毒，需要人来测试出毒酒是哪一瓶。每次测试结果8小时后才会得出，而大家只有8个小时的时间。问最少需要几人才能测试出毒酒是哪一瓶
>
> 答：3人，2^3=8

### 基本路径测试

- 点覆盖标准和语句覆盖标准是相同的
- 边覆盖和判定覆盖是一致的
- 路径覆盖的含义是:选取足够多测试数据，使程序的每条可能路径都至少执行一次(如果程序图中有环，则要求每个环至少经过一次)

#### 过程

- 画出流图

<img src="/images/1565852.png" alt="预览大图" style="zoom: 33%;" />

- 计算McCabe环路复杂度N+1=6

- 确定线性**独立路径**的基本集合
  - 独立路径至少包含一条在定义该路径之前**不曾用过的边**
  - 上述程序的环形复杂度为6，因此共有6条独立路径


<img src="/images/1565890.png" alt="预览大图" style="zoom: 50%;" />

- 设计可强制执行基本集合中每条路径的测试用例
  - 某些独立路径不能以独立的方式测试，这些路径必须作为另一个路径的一部分来测试。


### 条件测试

条件测试的目的不仅是检测程序条件中的错误，而且是检**测程序中的其他错误**。如果程序P的测试集能有效地检测P中条件的错误，则它很可能也可以有效地检测P中的其他错误

![image-20221227004043888](/images/image-20221227004043888.png)

### 循环测试

循环测试是一种白盒测试技术，它专注于测试循环结构的有效性。在结构化的程序中通常只有3种循环，即简单循环、串接循环和嵌套循环

![image-20221101201428744](/images/image-20221101201428744.png)



- 测试简单循环,n是允许通过循环的最大次数
  -  跳过循环
  -  只通过循环一次
  -  通过循环两次
  -  通过循环m次，其中m<n-1
  -  通过循环n-1,n,n+1次
- 嵌套循环
  - 对最内层循环使用简单循环测试方法，而使外层循环的迭代参数取最小值，并为越界值或非法值增加一些额外的测试

- 串接循环
  - 根据循环关系选择简单循环或嵌套测试


```
Selenium是一个用于Web应用程序测试的工具
```

# 调试

调试（也称为纠错）作为**成功测试的后果出现**，即调试是在测试发现错误之后排除错误的过程,是把症状和原因联系起来的尚未被人深入认识的智力过程

- **蛮干法/试探法**按照“让计算机自己寻找错误”的策略，这种方法印出内存的内容，激活对运行过程的跟踪，并在程序中到处都写上WRITE（输出）语句，效率低
- **回溯法**是一种相当常用的调试方法，当调试小程序时这种方法是有效的。具体做法：从发现症状的地方开始，人工沿程序的控制流往回追**踪分析源程序代码，直到找出错误原因为止**，**适合小程序**
- **原因排错法**
  - **对分查找法**的基本思路是，如果已经知道每个变量在程序内若干个关键点的正确值，则可以用赋值语句或输入语句在程序中点附近**“注入”这些变量的正确值**，然后运行程序并检查所得到的输出
  - **归纳法**是从个别现象推断出一般性结论的思维方法。使用这种方法调试程序时，首先把和错误有关的数据组织起来进行分析，以便发现可能的错误原因。然后**导出对错误原因的一个或多个假设，并利用已有的数据来证明或排除这些假设**
  - **演绎法**从一般原理或前提出发，经过排除和精化的过程推导出结论。采用这种方法调试程序时，首先**设想出所有可能的出错原因**，然后试图用测试来排除每一个假设的原因



https://blog.csdn.net/MarryLinDa/article/details/115031621

