---
title: "Fragment，Activity，Adapter交互"
description: 原创+转载
date: 2022-10-07T12:08:51Z
image: Android_symbol_green_2.max-1500x1500.png
math: 
license: 
hidden: false
comments: true
categories:
    - ANDROID
tags:
---


- Activity调用Fragment

```kotlin
//Activity 调用Fragment返回Fragment类
//用于获取Context与View
//仅限于写在xml内的Fragment
supportFragmentManager.findFragmentById()
//获取自定义Fragment实例
//多用于transaction.replace()
val firstFragment=FirstFragment()
```

- Fragment调用Fragment

```kotlin
//Fragment 调用 Activity中的控件
requireActivity().findViewById<View>(R.id.XXX)
// Fragment 调用同 Activity 下的Fragment
requireActivity().supportFragmentManager.findFragmentById()
//调用Activity自定义方法
val activity=activity as MainActivity
activity.method()
```

- Fragment调用Adapter

```kotlin
//直接调用
val adapter=FirstAdapter(itemList)
```

- Adapter调用Fragment

```kotlin
//Adapter作为Fragment inner类
inner class SecondAdapter(......)
//通用接口回调
```



- 通用的接口回调

　　所谓的回调，就是程序员 A 写了一段程序（程序 a ），其中预留有回调函数接口，并封装好了该程序。

　　程序员 B 要让 a 调用自己的程序 b 中的一个方法；

　　于是，他通过 a 中的接口回调自己 b 中的方法。

```kotlin
//A类定义接口
interface TestDataCallback {
    fun testData()
}
//B类重写方法
class MainActivity : AppCompatActivity(), FirstFragment.TestDataCallback {
    override fun testData() {
        Toast.makeText(this, "CallBack", Toast.LENGTH_SHORT).show()
    }
}
//A类调用B类重写的方法
if (activity is TestDataCallback) {
    (activity as TestDataCallback).testData()
}
//定义接口参数函数
fun setCallBack(testDataCallback: TestDataCallback){
    testDataCallback.testData()
}
//调用接口参数函数
if (activity is TestDataCallback) {
   setCallBack((activity as TestDataCallback))
}
```

- 其他
  - Handler
  - 广播
  - EventBus
  - Bundle和setArgments(bundle)

https://www.cnblogs.com/hyacinthLJP/p/14375051.html

https://blog.csdn.net/qq_33210042/article/details/108472447

https://blog.csdn.net/weixin_44008788/article/details/122262509?utm_medium=distribute.pc_relevant.none-task-blog-2~default~baidujs_baidulandingword~default-1-122262509-blog-108472447.pc_relevant_multi_platform_whitelistv3&spm=1001.2101.3001.4242.2&utm_relevant_index=4