---
title: "kotlin进阶语法二"
description: 学习
date: 2022-12-19T05:29:11Z
image: 
math: 
license: 
hidden: false
comments: true
categories:
 - ANDROID
tags:
---
## 高阶函数

- 如果一个函数接收另一个函数作为参数，或者返回值的类型是另一个函数，那么该函数就称为高阶函数。
- apply()，run()的实现
- 内联函数在编译时将Lambda表达式中的代码替换到函数类型参数调用的地方，消除Lambda表达式所带来的运行时开销

```
inline fun n1AndN2(func:(Int,Int)->Int):Int{
    return func(3,5)
}
//扩展高阶函数
fun StringBuilder.build(func: StringBuilder.()->Unit):StringBuilder{
    func()
    return this
}

fun printString(str: String, block: (String) -> Unit) {
    block(str)
}

inline fun printStringInline(str: String, block: (String) -> Unit) {
    block(str)

}

fun main(){
    //Lambda表达式
    n1AndN2 { n1, n2 ->
        n1+n2
    }
	//实现类似apply()的方法
    val result=StringBuilder().build {
        append("Start eat!")
    }
	//非内联函数局部返回
    val str = ""
    printString(str) { s ->
        if (s.isEmpty()) return@printString
        println(s)
    }
	//内联函数全局返回
    printStringInline(str) { s ->
        if (s.isEmpty()) return
        println(s)
    }

}

```

- 简化`contentValues()`


## 泛型

```kotlin
//泛型类
//默认情况泛型上界为Any?,泛型可以为空
class MyClass1<T:Any>{
    fun method(param1:T):T {
        return param1
    }
}
//泛型方法
class MyClass2{
    fun <T:Number> method(param1:T){
    }
}
//泛型方法
//高阶函数
//扩展函数
fun <T> T.build(block: T.() -> Unit):T{
    block()
    return this
}

val num=10
//需要指定类型
val myClass1=MyClass1<Int>()
myClass1.method(num)

val myClass2 = MyClass2()
//kotlin可以自动推理
myClass2.method(num)

num.build {
	println(this)
}

```


## 委托

如果我们只是让大部分的方法实现调用辅助对象中的方法，少部分的方法实现由自己来重写，甚至加入一些自己独有的方法，那么MySet就会成为一个全新的数据结构类，这就是委托模式的意义所在.

```kotlin
class MySet<T>(val helperSet: HashSet<T>) : Set<T> {
    //通用委托(delegate)模式
    //方便重写部分方法与加入特有方法
    override val size: Int
    get() = helperSet.size
    override fun contains(element: T) = helperSet.contains(element)
    override fun containsAll(elements: Collection<T>) = helperSet.containsAll(elements)
    override fun isEmpty() = helperSet.isEmpty()
    override fun iterator() = helperSet.iterator()
}

//kotlin特有的类委托(delegate)
//关键字为by
class MySet2<T>(private val helperSet: HashSet<T>):Set<T> by helperSet{
    fun helloWorld()= println("Hello world")
    override fun isEmpty() = false
}
```

p属性的具体实现委托给了Delegate类去完成。当调用p属性的时候会自动调用Delegate类的getValue()方法，当给p属性赋值的时候会自动调用Delegate类的setValue()方法。
```
class MyClass2{
    fun <T:Number> method(param1:T){

    }
	//委托属性
    var p by later {
        println("later")
        233
    }

}

//高阶函数返回实例化Later()
fun <T> later(block: () -> T) = Later(block)

class Later<T>(val block: () -> T){
    var value:Any?=null
    operator fun getValue(myClass2: MyClass2,prop:KProperty<*>):T{
        if (value==null){
            value=block()
        }
        return value as T
    }

    operator fun setValue(myClass2: MyClass2,prop:KProperty<*>,value: Any?){
        //propValue=value
    }
}
```