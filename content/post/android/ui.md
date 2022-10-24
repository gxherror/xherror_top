---
title: "UI"
description: 学习
date: 2022-10-22T13:14:27Z
image: 
math: 
license: 
hidden: false
comments: true
categories:
 - ANDROID
tags:
---
# 布局

布局是一种可用于放置很多控件的容器,也可以放置布局，通过多层布局的嵌套.

- LinearLayout又称作线性布局，是一种非常常用的布局。正如它的名字所描述的一样，这个布局会将它所包含的控件在线性方向上依次排列。
- RelativeLayout又称作相对布局，也是一种非常常用的布局。和LinearLayout的排列规则不同，RelativeLayout显得更加随意，它可以通过相对定位的方式让控件出现在布局的任何位置。
- FrameLayout又称作帧布局，它相比于前面两种布局就简单太多了，因此它的应用场景少了很多。这种布局没有丰富的定位方式，所有的控件都会默认摆放在布局的左上角。

## 控件和布局的继承结构

![c5e32e66cf0c85fd90bc3961cc5627db.png](/images/c5e32e66cf0c85fd90bc3961cc5627db.png)

![image-20221022141408741.png](/images/image20221022141408741.png)

## 尺寸

- px：pixel，1px代表屏幕上的⼀个物理像素点
  - 分辨率 1920 * 1080表示屏幕上有多少个物理像素点
- dpi：dots per inch，对⻆线每英⼨的像素点的个数；该值越⼤表示屏幕越清晰
  • 计算规则如下；1920 * 1080分辨率，5⼨屏幕，dpi为440
- density：dpi/160
- dp/dip：density-independent pixel，设备⽆关像素，**最多使用**
  -  =px/density
  -  1dp大小等同于160ppi屏幕上的1个像素大小
- sp：scale-independent pixel，与缩放⽆关的抽象像素
  - 与dp近似，但除了受屏幕密度影响外，还受到⽤户字体⼤⼩影响（正相关）

## PNG->9-Patch图片

![e2c6144f4d117d305f8fff8b9c88553e.png](/images/e2c6144f4d117d305f8fff8b9c88553e.png)
`layout-sw600dp`指定在屏幕宽度大于等于600 dp的设备进行加载