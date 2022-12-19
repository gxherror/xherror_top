---
title: "广播"
description: 学习 
date: 2022-12-19T05:41:29Z
image: 
math: 
license: 
hidden: false
comments: true
categories:
 - ANDROID
tags:
---
## 广播机制简介

Android中的每个应用程序都可以对自己感兴趣的广播进行注册，这样该程序就只会收到自己所关心的广播内容，这些广播可能是来自于系统的，也可能是来自于其他应用程序的。

- 标准广播（normal broadcasts）是一种完全异步执行的广播，在广播发出之后，所有的 BroadcastReceiver几乎会在同一时刻收到这条广播消息，因此它们之间没有任何先后顺 序可言。这种广播的效率会比较高，但同时也意味着它是无法被截断的。
- 有序广播（ordered broadcasts）则是一种同步执行的广播，在广播发出之后，同一时刻 只会有一个BroadcastReceiver能够收到这条广播消息，当这个BroadcastReceiver中的 逻辑执行完毕后，广播才会继续传递。所以此时的BroadcastReceiver是有先后顺序的， 优先级高的BroadcastReceiver就可以先收到广播消息，并且前面的BroadcastReceiver 还可以截断正在传递的广播。
- 隐式广播指的 是那些没有具体指定发送给哪个应用程序的广播，大多数系统广播属于隐式广播，但是少数特 殊的系统广播目前仍然允许使用静态注册的方式来接收。

## 接收系统广播

### 动态注册

```kotlin
class MainActivity : AppCompatActivity() { 
    lateinit var timeChangeReceiver: TimeChangeReceiver 
    override fun onCreate(savedInstanceState: Bundle?) { 
        super.onCreate(savedInstanceState) 
        setContentView(R.layout.activity_main) 
        val intentFilter = IntentFilter() 
        intentFilter.addAction("android.intent.action.TIME_TICK") 
        timeChangeReceiver = TimeChangeReceiver() 
        registerReceiver(timeChangeReceiver, intentFilter) 
    } 
    override fun onDestroy() { 
        super.onDestroy() 
        unregisterReceiver(timeChangeReceiver) 
    } 
    inner class TimeChangeReceiver : BroadcastReceiver() { 
        override fun onReceive(context: Context, intent: Intent) { 
            Toast.makeText(context, "Time has changed", Toast.LENGTH_SHORT).show()        		 }	 
    } 
}
```

完整的广播列表`<Android SDK>/platforms/<任意android api版本>/data/broadcast_actions.txt`

### 静态注册

静态注册是常驻型 ，也就是说当应用程序关闭后，如果有信息广播来，程序也会被系统调用自动运行。
静态注册多用于接收显式广播，只有少量隐式系统广播可通过权限申请进行接收。
单独文件广播注册New→Other→Broadcast Receiver

```kotlin
class BootCompleteReceiver : BroadcastReceiver() { 
    override fun onReceive(context: Context, intent: Intent) { 
        Toast.makeText(context, "Boot Complete", Toast.LENGTH_LONG).show()     } 
}
```

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<application>
	<receiver 
			  android:name=".BootCompleteReceiver" 
			  android:enabled="true" 
			  android:exported="true"> 
		  <intent-filter> 
			<action android:name="android.intent.action.BOOT_COMPLETED" />            			  </intent-filter> 
	 </receiver>
</application>
```

## 发射自定义广播

```kotlin
val intent =
Intent("top.xherror.firstactivity.MY_BROADCAST")
intent.setPackage(packageName)
//sendBroadcast(intent)
sendOrderedBroadcast(intent,null)
```

高优先级接收

```kotlin
<receiver
	android:name=".broadreceiver.MyReceiver"
	android:enabled="true"
	android:exported="true">
	<intent-filter android:priority="100" >
		<action android:name="top.xherror.firstactivity.MY_BROADCAST" />
	</intent-filter>
</receiver>
```

## 实现强制下线

在第一行代码中写到:

>创建的是一个静态注册的BroadcastReceiver，是没有办法在onReceive()方法里弹出对话框这样的UI控件的

因此书上采用动态注册，通过各种搜索找到了静态注册的方法：

```kotlin
class SignInReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val builder= AlertDialog.Builder(context)
        builder.run {
            setTitle("Warning")
            setMessage("You are forced to be offline.Please try to sign in again")
            setCancelable(false)
            setPositiveButton("OK"){dialog,which->
                BaseActivity.finishAll()
                val intent =Intent(context,SignInActivity::class.java)
				intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                context.startActivity(intent)
            }
        }
        val alterDialog = builder.create()
        //添加对话框类型：保证在广播中正常弹出
        alterDialog.window?.setType(WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY)
        alterDialog.show()
    }
}
```

Manifest中申请权限:

```xml
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>
```

申请权限后，当然需要用户**授权**，路径Apps->Advanced->Display over other Apps

![73c9b0bb1dc9ab907c12c661822c5b54.png](/images/73c9b0bb1dc9ab907c12c661822c5b54.png)

https://blog.csdn.net/weixin_43884551/article/details/107569418

https://blog.csdn.net/u012504392/article/details/53011172