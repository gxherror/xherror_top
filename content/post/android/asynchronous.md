---
title: "安卓异步加载"
description: 学习
date: 2022-12-19T04:59:11Z
image: 
math: 
license: 
hidden: false
comments: true
categories:
    - ANDROID
tags:
---
# Handler机制

There are two main uses for a Handler:
(1) to schedule messages and runnables to be executed at some point in the future;
(2) to enqueue an action to be performed on a different thread than your own.

```kotlin
val action = Runnable {
     findNavController().navigate(R.id.action_FirstFragment_to_SecondFragment)
}
val mainHandler = Handler(Looper.getMainLooper())

binding.buttonFirst.setOnClickListener {
     findNavController().navigate(R.id.action_FirstFragment_to_SecondFragment)
    mainHandler.removeCallbacks(action)
}

mainHandler.postDelayed(action, 3000)
```

![image-20221110011746002](/images/image-20221110011746002.png)

# 多线程

![image-20221112130118554](/images/image-20221112130118554.png)

## Thread

```kotlin
//handler处理消息
private val uploadHandler by lazy {
    Handler(Looper.getMainLooper()) { msg ->
        when (msg.what) {
            UploadManager.UPLOAD_PROGRESS -> {
                val progress = msg.obj as Float
                binding.progressCircleView.progress = progress
            }
        }
        true
    }
}
```

![image-20221112125525268](/images/image-20221112125525268.png)

```kotlin
object UploadManager: UploadCallback {
    const val UPLOAD_PROGRESS = 3

    private lateinit var  uploadThread :UploadThread
    private lateinit var  handler: Handler

    fun setHandler(handler: Handler){
        this.handler=handler
    }

    fun startUpload(progress: Float = 1f) {
        //每次start()要创建新实例!!
        uploadThread = UploadThread(this, handler,progress)
        uploadThread.start()
    }
    
    override fun onUploadSuccess() {
    }

    /**
     * 这两种方式都很常见
     * @param callback  回调
     * @param handler   利用Handler发送消息
     **/
    class UploadThread(private val callback: UploadCallback, private val handler: Handler): Thread() {
        override fun run() {
            try {
                upload()
                callback.onUploadSuccess()
            } catch (e: Exception) {
                
            }
        }
        private fun upload() {
            while (progress > 0f) {
                sleep(1000)
                handler.sendMessage(Message.obtain(handler, UPLOAD_PROGRESS, progress))
            }
        }
    }
}

/**
 * 回调也是一种很常见的写法
 */
interface UploadCallback {
    fun onUploadSuccess()
}
```



## ThreadPool

- 单个任务处理时间⽐较短且任务数量很⼤（多个线程的线程池）：
  -  ⽹络库：FixedThreadPool 定⻓线程池
  -  DB操作：CachedThreadPool 可缓存线程池
- 执⾏定时任务（定时线程池）：
  -  定时上报性能⽇志数据： ScheduledThreadPool 定时任务线程池
- 特定单项任务（单线程线程池）：
  -  ⽇志写⼊：SingleThreadPool 只有⼀个线程的线程池

## AsyncTsk

- Handler模式来实现的异步操作，代码相对臃肿，在多个任务同时执⾏时，不易对线程进⾏精确的控制。
- Android提供了⼯具类AsyncTask，它使创建异步任务变得更加简单，不再需要编写任务线程和Handler实例即可完成相同的任务

![image-20221112125802539](/images/image-20221112125802539.png)

```
1. AsyncTask<Params, Progress, Result>：UI线程
2. onPreExecute：UI线程

3. doInBackground：⾮UI线程

4. publishProgress：⾮UI线程

5. onProgressUpdate：UI线程

6. onPostExecute：UI线程
```

## HandlerThread

HandlerThread的本质：继承Thread类 & 封装Handler类

![image-20221112125951340](/images/image-20221112125951340.png)

## IntentService

- Service 是⼀个可以在后台执⾏⻓时间运⾏操作⽽不提供⽤户界⾯的应⽤组件,执⾏在主线程
- IntentService 是 Service 的⼦类，它使⽤⼯作线程逐⼀处理所有启动请求,不在主线程执⾏

## Other

Bolts-Android

RxJava

 Kotlin 协程

