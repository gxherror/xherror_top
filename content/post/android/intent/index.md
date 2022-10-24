---
title: "Intent"
description: 
date: 2022-09-29T01:23:36Z
image: 
math: 
license: 
hidden: false
comments: true
categories:
- ANDROID
tags:
---
## Intent

Intent是Android程序中各组件之间进行交互的一种重要方式，它不仅可以指明当前组件想要执行的动作，还可以在不同组件之间传递数据。Intent一般可用于启动Activity、启动Service以及发送广播等场景。Intent大致可以分为两种：显式Intent和隐式Intent。我们先来看一下显式Intent如何使用。

### 显式Intent

Intent有多个构造函数的重载，其中一个是Intent(Context packageContext, Class&lt;?&gt; cls)。这个构造数接收两个参数：第一个参数Context要求提供一个启动Activity的上下文；第二个参数Class用于指定想要启动的目标Activity，通过这个构造函数就可以构建出Intent的“意图”。

```
button1.setOnClickListener {
    val intent = Intent(this, SecondActivity::class.java)
    intent.putExtra("extra_data", data)
    startActivity(intent)
}
```
更好的Activity启动方法
```kotlin
class SecondActivity : BaseActivity() {
    companion object {
        fun actionStart(context:Context,data1:String,data2:String){
            val intent = Intent(context,SecondActivity::class.java)
            intent.putExtra("param1",data1)
            intent.putExtra("param2",data2)
            context.startActivity(intent)
        }
    }
}
```
Intent接收
```
class SecondActivity : AppCompatActivity() {
	override fun onCreate(savedInstanceState: Bundle?) {
		super.onCreate(savedInstanceState)
		setContentView(R.layout.second_layout)
		val extraData = intent.getStringExtra("extra_data")
	}
}
```




### 隐式Intent

相比于显式Intent，隐式Intent则含蓄了许多，它并不明确指出想要启动哪一个Activity，而是指定了一系列更为抽象的action和category等信息，然后交由系统去分析这个Intent，并帮我们找出合适的Activity去启动。

```
<activity android:name=".SecondActivity" >
    <intent-filter>
        <action android:name="com.example.activitytest.ACTION_START" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.MY_CATEGORY" />
    </intent-filter>
</activity>
```

只有&lt;action&gt;和&lt;category&gt;中的内容同时匹配Intent中指定的action和category时，这个Activity才能响应该Intent。

```
button1.setOnClickListener {
    val intent = Intent("com.example.activitytest.ACTION_START")
startActivity(intent)
}
```

每个Intent中只能指定一个action，但能指定多个category。目前我们的Intent中只有一个默认的category，那么现在再来增加一个吧。

```
button1.setOnClickListener {
    val intent = Intent("com.example.activitytest.ACTION_START")
    intent.addCategory("com.example.activitytest.MY_CATEGORY")
    startActivity(intent)
}
```

### 更多隐式Intent的用法

```kotlin
button1.setOnClickListener {
    val intent = Intent(Intent.ACTION_VIEW)
    //语法糖替代setData()	
    //val intent = Intent(Intent.ACTION_DIAL)
    //intent.data = Uri.parse("tel:10086")
    intent.data = Uri.parse("https://www.baidu.com")
    startActivity(intent)
}
```

## Intent返回数据

```kotlin
val toNormalActivity= registerForActivityResult(ActivityResultContracts.StartActivityForResult()){
    when(it.resultCode){
        RESULT_OK -> {
            val data=it.data?.getStringExtra("data_return")
            Log.d("NormalActivity","return data is $data")
        }
    }
}
binding.startNormalActivity.setOnClickListener {
    val intent=Intent(this,NormalActivity::class.java)
    intent.putExtra("extra_data","Hello NormalActivity")
    toNormalActivity.launch(intent)
}
```

```kotlin
override fun onBackPressed() {
    super.onBackPressed()
    val intent = Intent()
    intent.putExtra("data_return", "Hello FirstActivity")
    setResult(RESULT_OK, intent)
    finish()
```
