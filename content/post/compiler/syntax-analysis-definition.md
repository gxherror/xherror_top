---
title: "语法分析概念"
description: 学习
date: 2022-11-11T11:59:44Z
image: 
math: 
license: 
hidden: false
comments: true
categories:
    - COMPILER
tags:
---
## 概念

将单词流按照语法规则翻译成语法树

### 上下⽂⽆关⽂法（context-free grammar）

ternimal + nonternimal +production + start symbol  

具有比正则表达式更强的表达能⼒，可以用来表示正则

4 元组： (T, N, P, S) ，其中 T 为终结符集合， N 为非终结符集合， P 为产生式集合， S 为起始符号

含有零个终结符号的串称为空串，记为 Є

```
list -> list + digit | list – digit | digit
digit -> 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9
```

### 语法分析树

以树的形式展现了从⽂法的开始符号推导出符号串的过程

- 树的根结点的标号为⽂法的开始符号
- 每个叶⼦结点的标号为⼀个终结符号或者 Є
- 每个内部结点的标号为⼀个非终结符号

![image-20221110163020583](/images/image-20221110163020583.png)

### ⼆义性（ambiguous）

```
string -> string + string | string – string | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9
对 9 – 5 + 2，会得到两棵语法分析树
```

![image-20221110163721749](/images/image-20221110163721749.png)

### 推导

![image-20221110214039355](/images/image-20221110214039355.png)

### 实例

![image-20221110165232324](/images/image-20221110165232324.png)

## 文法设计

### 规则

- 右结合

![image-20221110163807611](/images/image-20221110163807611.png)

- 优先级

![image-20221110163824047](/images/image-20221110163824047.png)

### 消除⼆义性

```
 ⽂法： E -> E+E | E*E | (E) | id
 句⼦： id * id + id
 
 改写⽂法，考虑运算的计算优先顺序
 E -> E+T|T
 T -> T∗F|F
 F -> E | 𝐢𝐝
```



```
 “悬空-else”⽂法的⼆义性
stmt -> | if expr then stmt
		| if expr then stmt else stmt
		| other
		
区分内外层，实现else和最近未匹配的then匹配
stmt -> matched_stmt | open_stmt
matched_stmt -> | if expr then matched_stmt else matched_stmt
				| other
open_stmt -> | if expr then stmt
			 | if expr then matched_stmt else open_stmt
```

### 消除左递归

https://github.com/glebec/left-recursion

`𝐴 -> 𝐴𝛼 | 𝛽` ,𝛼 and 𝛽 are sequences of terminals and nonterminals

```
//不能直观上理解，从代码上理解
function Expr()
{  
    Expr();  match('+');  Term();
}
```

![image-20221111144654197](/images/image-20221111144654197.png)

#### 间接左递归

![image-20221111145225200](/images/image-20221111145225200.png)

### 提取左公因⼦

在推导过程中，当两个产⽣式具有相同的前缀⽽⽆法选择时，可以通过改写产⽣式，来推后这个选择决定

![image-20221111145407350](/images/image-20221111145407350.png)