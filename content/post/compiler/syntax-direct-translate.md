---
title: "语法制导翻译"
description: 学习
date: 2022-12-01T13:48:53Z
image: 
math: 
license: 
hidden: false
comments: true
categories:
    - COMPILER
tags:
---
## 语法制导翻译

采用**深度优先**遍历（depth-first）语法树

翻译实例：将中缀表达式翻译成后缀表达式

### 语法制导定义（syntax-directed definition）

- 将每个⽂法符号和⼀个属性集合（比如数值及类型）相关联

- 将每个产⽣式和⼀组语义规则相关联，用于计算⽂法符号相应的属性值

- 综合属性和继承属性

  - `syn`:通过N的⼦结点或N本身的属性值来定义
  - `inh`:通过N的⽗结点、N本身和N的兄弟结点上的属性值来定义

- 对SDD求值，依赖图，S属性和L属性的SDD

  - S属性的SDD:自底向上求值,只包含syn,通常与LR一起实现

  - L属性的SDD:自顶向下求值,包含inh与syn,通常与LL一起实现

    - 如`A->XYZ`其中`Y.syn`只能来自`A,X,Y`
    - ![image-20221201204218516](/images/image-20221201204218516.png)

  - 在依赖图中，继承属性从左到右或从上到下，综合属性从下到上

    - ![image-20221201204250973](/images/image-20221201204250973.png)

  - 变量声明的SDD中的副作用

    - ![image-20221201204531825](/images/image-20221201204531825.png)

    


### 抽象语法树（Abstract Syntax Tree，AST）

https://astexplorer.net/ 

语法分析树则称为具体语法树（Concrete Syntax Tree）

- 常作为编译器的中间表示
- 每个结点代表⼀个语法结构：对应于⼀个**运算符**
- 结点的每个⼦结点代表其⼦结构：对应于**运算分量**
- 可以忽略掉⼀些标点符号等非本质的东西
- 赋值语句的抽象语法树AST
  - ![image-20221201205352323](/images/image-20221201205352323.png)![image-20221201205320423](/images/image-20221201205320423.png)

利用S属性的SDD定义构造抽象语法树

![image-20221201205559638](/images/image-20221201205559638.png)

利用L属性的SDD定义构造抽象语法树

<img src="/images/image-20221201205727022.png" alt="image-20221201205727022" style="zoom: 67%;" />

![image-20221201205740557](/images/image-20221201205740557.png)

### 语法制导翻译⽅案（syntax-directed translation scheme）

- 在⽂法产⽣式中附加⼀些程序片段来描述翻译结果的表示⽅法
- 注意代码片段的插入**位置**
- 后缀SDT：实现S属性的SDD
- 产⽣式内部带有语义动作的SDT
  - 产⽣式 `B -> X{a}Y`
  - 自底向上分析时，在X出现在栈顶时执⾏动作a
  - 自顶向下分析时，在试图展开非终结符号Y或者在输⼊中检测到终结符号Y之前执⾏动作a

- 消除左递归的SDT：实现L属性的SDD
  - ![image-20221201210852856](/images/image-20221201210852856.png)

- 将L属性的SDD转换为SDT的规则
  - 计算某个非终结符号A的继承属性的动作，插⼊到产⽣式体中紧靠A出现之前
  - 将计算产⽣式头的综合属性的动作，放置在产⽣式体的最右端

