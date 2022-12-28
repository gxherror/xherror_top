---
title: "软考中级软件设计师"
description: 学习记录
date: 2022-12-26T11:19:09Z
image: software-design-cloud-tag595x335_0.jpg
math: 
license: 
hidden: false
comments: true
categories:
 - SE
tags:
---
# 前述

- 记录本人软考中级软件设计师的一些学习记录与错题记录,主要是主观题
- 之前看过CSAPP,OSETP,DBMS,C++设计和一部分SE,花了大概两周刷了近5年的题,简单看了设计模式与软件设计师教程,最后上午成绩：59.00,下午成绩：67.00
- [设计模式参考](https://refactoringguru.cn/design-patterns/catalog),软件工程可以[参考](https://github.com/synebula/SoftwareEngineerExam/blob/master/%E8%BD%AF%E4%BB%B6%E8%AE%BE%E8%AE%A1%E5%B8%88/%E4%B9%A6%E7%B1%8D%E6%95%99%E7%A8%8B%E8%B5%84%E6%96%99%20PDF/%E8%BD%AF%E4%BB%B6%E8%AE%BE%E8%AE%A1%E5%B8%88%E6%95%99%E7%A8%8B%E7%AC%AC5%E7%89%88.%E9%AB%98%E6%B8%85.pdf),或者是我SE系列的博客QWQ

# 选择

- 某计算机系统中互斥资源R的可用数为8，系统中有3个进程P1、P2和P3竞争R，且每个进程都需要i个R，该系统可能会发生死锁的最小i值为( )。
- 某航空公司拟开发一个机票预订系统， 旅客预订机票时使用信用卡付款。付款通过信用卡公司的信用卡管理系统提供的接口实现。若采用数据流图建立需求模型，则信用卡管理系统是( )。
- 某操作系统文件管理采用索引节点法。每个文件的索引节点有8个地址项，每个地址项大小为4字节，其中5个地址项为直接地址索引，2个地址项是一级间接地址索引，1个地址项是二级间接地址索引，磁盘索引块和磁盘数据块大小均为1KB。若要访问文件的逻辑块号分别为1和518，则系统应分别采用( )。
- 概要设计的内容可以包含系统构架、模块划分、系统接口、数据设计4个主要方面的内容
- 工作量估算模型 COCOMO II的层次结构中,估算选择不包括( )
- 在程序执行过程中，Cache与主存的地址映射是由( )完成的。
- 内存按字节编址。若用存储容量为32Kx8bit的存储器芯片构成地址从AOOOOH到DFFFFH的内存，则至少需要( )片芯片
- 配置管理是软件开发过程的重要内容，贯穿软件开发的整个过程。其内容包括：软件配置标识、变更管理、版本控制、系统建立、配置审核和配置状态报告
- 根据我国商标法，下列商品中必须使用注册商标的是()
- 在进行软件开发时，采用无主程序员的开发小组，成员之间相互平等;而主程序员负责制的开发小组，由一个主程序员和若干成员组成，成员之间没有沟通。在一个由8名开发人员构成的小组中，无主程序员组和主程序员组的沟通路径分别是( )。

# 数据流图题

## 数据库名称

XX信息表  ， XX 信息储存

## 补全数据及起点和终点

- 根据文字描述补
- 根据图1-1补
- 一分一条

![image-20221023130803009](/images/image-20221023130803009.png)

## 结构化语言

```
缺陷检测｛
    WHILE(接收图像)
    DO{
        检测所收到的所有图像；
        IF(出现一张图像检测不合格)
            THEN{
            返回产品不合格；
            不合格产品检测结果=产品星号+不合格类型；
            }
        ENDIF
    } ENDDO
｝
```

![image-20221102164202981](/images/image-20221102164202981.png)

## 问题4

https://blog.csdn.net/u010164936/article/details/45789475

- ![image-20221103122941635](/images/image-20221103122941635.png)

![image-20221103123315657](/images/image-20221103123315657.png)

- 分解子加工，分解常见的错误

![image-20221103152740858](/images/image-20221103152740858.png)

![image-20221103152752461](/images/image-20221103152752461.png)



# ER图题

- 【需求分析】
- 【联系】
- 【关系模式】
- 【关系】
- 【关系类型】
- 【概念模式设计】

![image-20221102170124712](/images/image-20221102170124712.png)

## ER图1：*关系

![image-20221023131809874](/images/image-20221023131809874.png)

补充属性用画圆的

![img](/images/v2-ae1112c97b59789dda7b35e22d877daf_720w.png)

- 问缺失的联系与联系类型

缺失的联系：员工与部门的隶属关系，联系类型：*：1类型

- 弱关系

![image-20221103125601180](/images/image-20221103125601180.png)

## 问题2

![image-20221102165914359](/images/image-20221102165914359.png)

可以填多个！！！！！

## 问题3

![image-20221102165957096](/images/image-20221102165957096.png)

## 问题4

- 在职员关系模式中，假设每个职员有多名家庭成员，那么职员关系模式存在什么问题？应如何解决？

```
在职员关系中，如果每个职员有多名家庭成员，会重复记录多条职员信息及对应家庭成员，为了区分各条记录，职员关系的主键需要设定为(职员号，家庭成员姓名)，会产生数据冗余、插入异常、更新异常、删除异常等问题。
处理方式：
对职员关系模式进行拆分，职员1(职员号、姓名、岗位、所属业务部编号，电话)；职员2(职员号，家庭成员姓名，关系)。
```

- 传递函数依赖

员工号-> 岗位，岗位->基本工资

- ![image-20221103121958007](/images/image-20221103121958007.png)

![image-20221103122009566](/images/image-20221103122009566-1667449211376-1.png)

- ![image-20221103180328515](/images/image-20221103180328515.png)

![image-20221103180312617](/images/image-20221103180312617.png)

# 用例图题

- https://wangxiao.xisaiwang.com/tiku2/exam506974737.html

18上半年做的很烂

![image-20221103182059857](/images/image-20221103182059857.png)





## 问题3

- 用例描述

![image-20221023202752771](/images/image-20221023202752771.png)

购买书籍用例描述：
参与者顾客
主要事件流：
1、顾客登录系统；
2、顾客浏览书籍信息；
3、系统检查某种书籍的库存量是否为0；
4、顾客选择所需购买的书籍及购买数量；
5、系统检查库存量是否足够；
6、系统显示验证验证界面；
7、顾客验证；
8、系统自动生成订单；
备选事件流：
3a. 若库存量为0则无法查询到该书籍信息，退回到2；
5a. 若购买数量超过库存量，则提示库存不足，并退回到4；
7a. 若验证错误，则提示验证错误，并退回到6；
8a. 若顾客需要可以选择打印订单。

# 类图

注意!!!!:C1 ,C2与C3是泛化关系

![image-20221102213157263](/images/image-20221102213157263.png)

# 算法题

https://blog.csdn.net/xiaornshuo/article/details/117532044

- 21上!!!!!

![img](/images/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3hpYW9ybnNodW8=,size_16,color_FFFFFF,t_70.png)![img](../_resources/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3hpYW9ybnNodW8=,size_16,color_FFFFFF,t_70-1667475032372-31.png)![img](../_resources/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3hpYW9ybnNodW8=,size_16,color_FFFFFF,t_70-1667475041482-34.png)![img](../_resources/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3hpYW9ybnNodW8=,size_16,color_FFFFFF,t_70-1667475052678-37.png)

```
1：r<=N
2：j=i+r-1
3：temp<m[i][j]
4：s[i][j],j->s[i][j],j
动态规划，O(N^3),O(N^2)
```



- 21下!!!!

![image-20221103182129683](/images/image-20221103182129683.png)

<img src="/images/image-20221103182152982.png" alt="image-20221103182152982" style="zoom:200%;" />

```
1：d[0][j]=0
2：str1[i-1]==str2[j-1]
3：d[i-1][j-1]+1
4：d[len1][len2]
动态规划，O(nm)
4
```



- 20下 - 希尔排序

```c
#include <stdio.h>
void shellsort(int data[ ], int n){
    int *delta,k,i,t,dk,j;
    k=n;
    delta=(int *)malloc(sizeof(int)*(n/2));
    if(i=0)
        do{
            ( 1:k=k/2 ) ; 
            delta[i++]=k;
        }while ( 2:i<n/2 ->k>1 ) ; 
    i=0;
    while((dk=delta[i])>0){
        for(k=delta[i];k<n;++k)
        if( ( 3:data[k]<data[k-dt]) ) { 
            t=data[k];
            for(j=k-dk;j>=0&&t<data[j];j-=dk){
                data[j+dk]=data[j];
            }/*for*/
        ( 4:data[j+dk]=t ) ; 
        }/*if*/
        ++i;
    }/*while*/
}
```

- 19上 - n皇后

```c
//2:回溯
//3：2 （ 2 4 1 3）与（ 3 1 4 2）
#include 
#define n 4
int queen[n+1];
void Show() {
	/* 输出所有皇后摆放方案 */
	int i;
	printf("(");
	for (i=1;i<=n;i++) {
		printf(" %d",queen[i]);
	}
	printf(")\n");
}
int Place(int j) {
	/* 检查当前列能否放置皇后，不能放返回0，能放返回1 */
	int i;
	for (i=1;i< j;i++){
        if( (1:queen[i]==queen[j]) ) ‖ abs(queen[i]-queen[j]) == (j-i)) {
            return 0;
        }
	}
	return (2:1) ;
}
void Nqueen(int j) {
int i;
for (i=1;i<=n;i++) {
	queen[j] = i;
	if( (3:Place(j)->Place(j)&&j<=n) ) {
		if(j == n) {
			/* 如果所有皇后都摆放好，则输出当前摆放方案 */
			Show();
		} else {
			/* 否则继续摆放下一个皇后 */
			(4:Nqueen(++j)) ;
		}
	}
}
}
int main() {
Nqueen (1) ;
return 0;
}
```

- 19下背包问题

  ![img](/images/hXdkpIhSY2.png)

  ![img](/images/BA4Gb9TYWK.png)

  ```
  1:c[i][j]
  2:i>0&&j>=w[i]
  3:Calculate_Max_Value(v,w,i-1,j-w[i])+w[i]
  4:c[i][j]=temp
  动态规划，自顶向下
  40
  ```


- 18下

![img](/images/5fa4d1b402674dd1872bfa1527b4b89a_.png)

![image-20221102235804388](/images/image-20221102235804388.png)![image-20221102235804630](../_resources/image-20221102235804630.png)

```
ACGCAACAGU
-CGCAACAG-
ACGC-ACAGU
------------
1:max=C[i][j-1
]
2:t=i
3:isMatch(B[t],B[j])
4:C[1][n]
动态规划，O(N^3)
2
```

- 18上

![image-20221103131825154](/images/image-20221103131825154.png)

![image-20221103131842663](/images/image-20221103131842663.png)

```
1：i<=n
2：i<=j
3：(temp>=(r[j-i]+p[i]))?temp:(r[j-i]+p[i])
4：r[j]=temp
动态规划，O(N^N)->O(2^N),O(N^2)
```



# JAVA

- 21下- flyweight

![img](/images/aGdR6XDY5q.png)

![image-20221103184724137](/images/image-20221103184724137.png)

![image-20221103184751723](/images/image-20221103184751723.png)

![image-20221103184936625](/images/image-20221103184936625.png)

![image-20221103184838214](/images/image-20221103184838214.png)

```java
1:public abstract void draw()
2:Piece
3:Piece
4:piece.draw()
5:piece.draw()
```



- 20下 - mediator

![img](/images/a42b94b433df400280215335b7d1978a.jpeg)

![img](/images/579bd48f857c4bdd8838955edef09072.jpeg)

(1):void buy(double money ,WebService service)

(2):WebServiceMediator

(3):abstract void buyService(double money)

(4):this.mediator.buy(money,this) ->mediator.buy(money,this)

(5):this.mediator.buy(money,this) ->mediator.buy(money,this)

- 19上-Strategy

![img](/images/fe743564b30b5a4c77473c67f9450840.png)

```java
import java.util.*;

interface BrakeBehavior {
	public (1:void stop());
/* 其余代码省略 */
};

class LongWheelBrake implements BrakeBehavior {
	public void stop()
	{
		System.out.println( "模拟长轮胎刹车痕迹！ " );
	}
/* 其余代码省略 */
};


class ShortWheelBrake implements BrakeBehavior {
	public void stop()
	{
		System.out.println( "模拟短轮胎刹车痕迹！ " );
	}


/* 其余代码省略 */
};

abstract class Car {
	protected (2:BrakeBehavior) wheel;
	public void brake()
	{
		(3:wheel.stop());
	}
/* 其余代码省略 */
} ;

class ShortWheelCar extends Car {
	public ShortWheelCar( BrakeBehavior behavior )
	{
		(4:wheel=behavior);
	}
/* 其余代码省略 */
};

class StrategyTest {
	public static void main( String[] args )
	{
		BrakeBehavior	brake	= new ShortWheelBrake();
		ShortWheelCar	car1	= new ShortWheelCar( brake );
		car1.(5:brake());
	}
}

```

- 19下

![img](/images/nvRrMUebn7.png)

![img](/images/cwLxDc2De9.png)

![img](/images/FrT8uUMtZV.png)

![img](/images/rtIEdYZdZ0.png)

```java
1:void update()
2:Observer
3:obs.update()
4:Subject
5:Attach(this)
```

- 18下

![img](/images/fc745d103c9646dda3924a4f9dc6b2cd_.png)

![img](/images/425c555be2984aa5a74714d2a20bc7b8_.png)

```java
1：double travel(int miles ,FrequentFlyer context)->abstract double travel(int miles ,FrequentFlyer context)
2：context.setState(new CSilver())
3：context.setState(new CGold())
4：context.setState(new CSilver())
5：context.setState(new CBasic())
---------------------------------------
abstract class CState{
    public int flyMiles;
    //抽象类的抽象方法不用函数体
    public abstract double travel();
}


class CGold extends CState{
    public double travel(){
        System.out.println("traveling");
        return 0.0;
    }
}


```

- 18上

![img](/images/6de9317b550447b99910ba68caa4bb7e_.png)

![image-20221103143408913](/images/image-20221103143408913.png)

```java
1：Product getResult()
2：void buildPartA()
3：product.setPartA
4：product.setPartB
5：builder.getResult()
-------------------------
//接口是隐式抽象的，当声明一个接口的时候，不必使用abstract关键字。
//接口中每一个方法也是隐式抽象的，声明时同样不需要abstract关键字。
//接口中的方法都是公有的。
接口的继承,接口允许多继承!!
public interface Hockey extends Sports, Event
public interface Sports
{
   public void setHomeTeam(String name);
   public void setVisitingTeam(String name);
}
public interface  Event{
    ......
}
```

https://wangxiao.xisaiwang.com/tiku2/exam506986474.html

https://blog.csdn.net/WHT869706733/article/details/124136146

https://blog.csdn.net/qq_41471057/article/details/109388180