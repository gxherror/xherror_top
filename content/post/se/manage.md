---
title: "项目管理"
description: 学习 
date: 2022-11-06T06:29:06Z
image: 
math: 
license: 
hidden: false
comments: true
categories:
 - SE
tags:
---
## 管理

集中在4P

- Person+Product+Project+Procedure

## 成本估计

- 代码行技术 
- 任务分解技术 
- 自动估计成本技术

### 工作量估算模型

- Walston-Felix模型

  KLOC（kilo lines of code）=功能点*语言具体行数/1000

  E ＝ 5.2×(KLOC)^0.91， **KLOC**是源代码行数，**E**是工作量（以PM/（Person/Month）计）

  D ＝ 4.1×(KLOC)^0.36，**D**是项目持续时间(以月计)

  S ＝ 0.54×E^0.6，**S**是人员需要量(以人计)

  DOC ＝ 49×(KLOC)^1.01 ，**DOC**是文档数量(以页计)

- COCOMO-81

  - 模型级别有**三个等级**+项目类型有**三种类型**
  - E= a × (KLOC)^b × 乘法因子(以PM计)，**其中：**

​				a、b是**系数**	

​				乘法因子是中等COCOMO**对公式的校正系数**

- COCOMOll

![image-20221104224710065](/images/image-20221104224710065.png)

- Putnam模型

动态多变量模型，设定工作量的分布，大型软件项目

![image-20221104225053203](/images/image-20221104225053203.png)



## 进度管理

- Gantt图

![image-20221104225405981](/images/image-20221104225405981.png)

- PERT图

![image-20221104225437583](/images/image-20221104225437583.png)

## 配置管理SCM

- 基线
- 软件配置项
- 版本控制
- 变更控制

## 风险管理

![image-20221104230011733](/images/image-20221104230011733.png)

https://juejin.cn/post/7035886400985628679