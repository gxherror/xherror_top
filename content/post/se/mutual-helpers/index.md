---
title: "互帮互助软件"
description: 项目
date: 2022-12-19T05:00:56Z
image: image-20221219104125176.png
math: 
license: 
hidden: false
comments: true
categories:
 - SE
tags:
---
# 第二次迭代

CS3331-1-软件工程大作业，参考《第一行代码 第三版》

[主文件](https://github.com/gxherror/MutualHelpers/blob/main/app/src/main/java/top/xherror/mutualhelpers/MainActivity.kt) [APP](https://github.com/gxherror/MutualHelpers/blob/main/app/release/app-release.apk) [博客](https://xherror.top/post/se/mutual-helpers/)

<img src="/images/Screenshot_2022-12-19-11-33-17-450_top.xherror.mutualhelpers.png" alt="Screenshot_2022-12-19-11-33-17-450_top.xherror.mutualhelpers" style="zoom:25%;" /><img src="/images/Screenshot_2022-12-19-11-37-10-653_top.xherror.mutualhelpers.png" alt="Screenshot_2022-12-19-11-37-10-653_top.xherror.mutualhelpers" style="zoom:25%;" /><img src="/images/Screenshot_2022-12-19-11-33-24-689_top.xherror.mutualhelpers.png" alt="Screenshot_2022-12-19-11-33-24-689_top.xherror.mutualhelpers" style="zoom: 25%;" /><img src="/images/Screenshot_2022-12-19-11-39-25-374_top.xherror.mutualhelpers.png" alt="Screenshot_2022-12-19-11-39-25-374_top.xherror.mutualhelpers" style="zoom:25%;" />



## 整体设计

- 安卓部分
  - 整体框架使用Activity套Fragment，后续考虑换成更流行的Viewpager2加Fragment
  - UI采用NestedScrollView嵌套RecycleView实现滑动与列表实现
  - UI模仿柠檬的布局，白绿粉蓝配色
- 数据库部分
  - item的储存采用原生的关系数据库SQLite加ORM模型Room
  - person与其他metadata采用原生的KV数据库SharedPreferences
  - 后序将person的储存也换成关系数据库方便进行DA
  - 使用Gson实现储存的Json格式与运行时ArrayList转换
- 网络部分(未完成)
  - 三层架构，即client-server-database
  - 使用Gin框架实现RESTFUL API，做为前端服务器
  - 使用Glide实现远端图片的获取，图片的异步加载与本地缓存

## 特色

- UI设计较为简单，更多重点在后端逻辑部分
- 实现了留言功能，方便双方的交流
- 动态类别修改，分类搜索，简单的模糊搜索(水壶->水杯)
- 密码采用SHA256加密储存，实现记住密码自动登入功能

## General Design

- Android
  - total framework design use Activity together with Fragment, would change to Viewpager2 together with Fragment in future
  - UI design uses NestedScrollView nests RecycleView to implement screen scroll and list show
  - UI design imitates SJTU lemon design style,use white-green-pink-blue color scheme
- Database
  - item storage use native ralational database SQLite with native ORM model Room
  - person and other metadata storage use native key-value database SharedPreference
  - hope to change person storage model to relational database for the sake of data analysis in future
  - use Gson to convert between storage format Json and runtime format ArrayList
- Network(unfinished)
  - three-tier architecture,namely client-server-database
  - use Gin framework to implement RESTFUL API,work as frontend server
  - use Glide to get remote images,asynchronous load and local cache

## Features

- UI design is relative simple，attach more importance on backend logic design
- implement comment utility，make communication easier
- dynamic category edit,classified saerch,simple huzzy search
- encrypt password use SHA256 when storage, implement remember password and auto login in utility

## UML
### Class Diagram

<img src="/images/image-20221219104125176.png" alt="image-20221219104125176"  />

### Use Case Diagram

![image-20221219111609855](/images/image-20221219111609855.png)

### Sequence Diagram

![image-20221219111532535](/images/image-20221219111532535.png)



# 第一次迭代

## 计划

在疫情期间，各个小区居民发挥互助精神，进行物品交换，互通有无。编写一个物品交换软件

该程序允许添加物品的信息，删除物品的信息，显示物品列表，也允许查找物品的信息。

利用国庆期间，结合本学期所学习的安卓原生开发知识，开发一个简单的物品交换APP，实现以上功能

## 开发

### 需求分析

- 允许添加物品的信息✓
- 删除物品的信息✓(还有BUG...)
- 显示物品列表✓
- 查找物品的信息✓
- （附加）用户管理X
- （附加）分类与模糊查询X

### 具体设计

主要以Activity+三个Fragment为整体框架，利用transaction实现我的物品与全部物品的切换，搜索框采用SearchView实现，添加物品的信息采用悬浮按键FloatingActionButton+Intent实现，物品列表利用RecyclerView实现

## 记录用时

```
optimize code and enable camera --2022/10/11 15:53
release:MutualHelper-v1.1N 		 --2022/10/7 19.46
release:MutualHelper-v1.0  		 --2022/10/7 11:31
TODO:load image        		  --2022/10/6 23:13
TODO:upload image        	 --2022/10/6 0:24
init                 	--2022/10/5 20:01
```

大致用时三天，在图片上传，储存，加载方面用时较久，在DEBUG方面也耗费较多时间

## 测试报告

UI美观方面较差，基本逻辑处理正确，但图片上传存在不同步的BUG

<img src="/images/e15aa0cf7a8f2f51acff761008739fa3.png" alt="e15aa0cf7a8f2f51acff761008739fa3.png" width="298" height="565" class="jop-noMdConv"> <img src="/images/2775b0c173315f4eaa0f48e4316442ea.png" alt="2775b0c173315f4eaa0f48e4316442ea.png" width="294" height="559" class="jop-noMdConv"><img src="/images/e2585e5d727cadb7dc34c3776c160e37.png" alt="e2585e5d727cadb7dc34c3776c160e37.png" width="289" height="551" class="jop-noMdConv">

## 事后总结

- 安卓开发学习的一次实践。还有很多需要学习的地方
- 整体框架设计较为混乱，存在冗余代码
- 局部耦合与分离没有明确

## 改进计划

- 完善用户管理

- 优化查询

- 将数据库转移道服务器，实现线上交互

  [项目仓库](https://github.com/gxherror/MutualHelpers)

  [APP安装包](https://github.com/gxherror/MutualHelpers/blob/main/app/release/app-release.apk)





