---
title: "kotlin进阶语法"
description: 学习
date: 2022-12-19T05:28:24Z
image: 
math: 
license: 
hidden: false
comments: true
categories:
 - ANDROID
tags:
---
## with

with函数接收两个参数：第一个参数可以是一个任意类型的对象，第二个参数是一个Lambda表达式。with函数会在Lambda表达式中提供第一个参数对象的上下文，并使用Lambda表达式中的最后一行代码作为返回值返回。

```kotlin
fun eatFruitUseWith(){
    val list= listOf<String>("Apple","Banana","Pear")
    val result= with(StringBuilder()){
        append("Start eating fruits.\n")
        for (fruit in list){
            append("$fruit\n")
        }
        append("End!")
        toString()
    }
    println(result)
}
```

## run

首先run函数通常不会直接调用，而是要在某个对象的基础上调用；其次run函数只接收一个Lambda参数，并且会在Lambda表达式中提供调用对象的上下文。其他方面和with函数是一样的，包括也会使用Lambda表达式中的最后一行代码作为返回值返回。

```kotlin
fun eatFruitUseRun(){
    val list= listOf<String>("Apple","Banana","Pear")
    val result= StringBuilder().run{
        append("Start eating fruits.\n")
        for (fruit in list){
            append("$fruit\n")
        }
        append("End!")
        toString()
    }
    println(result)
}
```

## apply?

apply函数和run函数也是极其类似的，都要在某个对象上调用，并且只接收一个Lambda参数，也会在Lambda表达式中提供调用对象的上下文，但是apply函数无法指定返回值，而是会自动返回调用对象本身。

```kotlin
fun eatFruitUseApply(){
    val list= listOf<String>("Apple","Banana","Pear")
    val result= StringBuilder().apply{
        append("Start eating fruits.\n")
        for (fruit in list){
            append("$fruit\n")
        }
        append("End!")
        toString()
    }
    println(result)
}
```

## as

## Kotlin静态方法

静态方法在某些编程语言里面又叫作类方法，指的就是那种不需要创建实例就能调用的方法，所有主流的编程语言都会支持静态方法这个特性。

- 使用单例类的方式
- 使用`companion object{ fun doAction(){} }`
- 定义真正的静态方法， Kotlin仍然提供了两种实现方式：注解和顶层方法。
  - 给单例类或`companion object`中的方法加上`@JvmStatic`注解
  - 定义一个顶层方法，顶层方法指的是那些没有定义在任何类中的方法，比如我们在上一节中编写的`main()`方法

### 静态变量（全局变量）

- 对于普通成员变量，每创建一个该类的实例就会创建该成员变量的一个拷贝，分配一次内存。由于成员变量是和类的实例绑定的，所以需要通过对象名进行访问，而不能直接通过类名对它进行访问。

- 而对于静态变量在内存中只有一份，java虚拟机（JVM）只为静态变量分配一次内存，在加载类的过程中完成静态变量的内存分配。由于静态变量属于类，与类的实例无关，因而可以直接通过类名访问这类变量。

## 密封类

```
interface Result
class Success(val msg: String) : Result
class Failure(val error: Exception) : Result
fun getResultMsg(result: Result) = when (result) {
	is Success -> result.msg
	is Failure -> result.error.message
	else -> throw IllegalArgumentException()
}
```

```
sealed class Result
class Success(val msg: String) : Result()
class Failure(val error: Exception) : Result()
fun getResultMsg(result: Result) = when (result) {
	is Success -> result.msg
	is Failure -> "Error is ${result.error.message}"
}
```

## 扩展函数★

- 统计字符串中字母的数量,构造StringUtil单例类，然后在这个单例类中定义了一lettersCount()函数，该函数接收一个字符串参数`StringUtil.lettersCount(str)`
- 但是有了扩展函数之后就不一样了，我们可以使用一种**更加面向对象的思维**来实现这个功能，比如说将lettersCount()函数添加到String类当中
- String类是一个final类，任何一个类都不可以继承它，也就是说它的API只有固定的那些而已，至少在Java中就是如此。然而到了Kotlin中就不一样了，我们可以向String类中扩展任何函数，使它的API变得更加丰富。

```
fun String.lettersCount(): Int {
	var count = 0
	for (char in this) {
		if (char.isLetter()) {
			count++
		}
	}
	return count
}
```

## 运算符重载

```
class Money(val value: Int) {
	operator fun plus(money: Money): Money {
		val sum = value + money.value
		return Money(sum)
	}
	operator fun plus(newValue: Int): Money {
		val sum = value + newValue
		return Money(sum)
	}
}
```

![ed954331c83a91832faa16367b15fb41.png](/images/ed954331c83a91832faa16367b15fb41.png)

## infix函数

- infix函数是不能定义成顶层函数的，它必须是某个类的成员函数，可以使用扩展函数的方式将它定义到某个类当中
- 其次，infix函数必须接收且只能接收一个参数，至于参数类型是没有限制的

```
infix fun <T> Collection<T>.has(element: T) = contains(element)

if (list has "Banana") {
	// 处理具体的逻辑
}
```

