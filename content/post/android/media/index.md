---
title: "多媒体"
description: 学习
date: 2022-10-13T04:35:51Z
image: 
math: 
license: 
hidden: false
comments: true
categories:
    - ANDROID
tags:
---
# Notification

- 流程`NotificationManager -> NotificationChannel -> Notification`
- 可以在Activity,BroadcastReceiver,Servive中创建

```kotlin
override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    val binding= ActivityNotificationBinding.inflate(layoutInflater)
    setContentView(binding.root)
    //全局唯一
    val channelId="0"
    val channelName="通知"
    //HIGH,DEFAULT,LOW,MIN
    val importance= NotificationManager.IMPORTANCE_HIGH
    
    val manager=getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    manager.createNotificationChannel(NotificationChannel(channelId,channelName,importance))
    val intent=Intent(this,NormalActivity::class.java)
    //使用androidx中的NotificationCompat兼容所有版本
    val notification=Notification.Builder(this,channelId)
    	//PendingIntent实现跳转
        .setContentIntent(PendingIntent.getActivity(this,0, intent,PendingIntent.FLAG_IMMUTABLE))
        .setContentTitle("Title")
        .setContentText("TextTextText")
        .setSmallIcon(R.drawable.ic_launcher_foreground)
        .setAutoCancel(true)
        .setStyle(Notification.BigPictureStyle().bigPicture(
            BitmapFactory.decodeResource(resources,R.drawable.banana)))
        .setLargeIcon(BitmapFactory.decodeResource(resources,R.drawable.apple))
        .build()
    //notification 唯一ID
    manager.notify(0,notification)
    //manager.cancel(0)
}
```



# Video

- 使用`MediaPlayer`与`VideoView`实现
- `VideoView`是对`MediaPlayer`进行简单封装

![a36249d9787997f175dbe96486b2ebdb.png](/images/a36249d9787997f175dbe96486b2ebdb.png)



- audio放在assets中,使用assetsManager进行管理;video放在raw中,使用R进行管理

```kotlin
val assetManager=assets
val fd=assetManager.openFd("asking-for-a-date.mp3")
mediaPlayer.setDataSource(fd.fileDescriptor,fd.startOffset,fd.length)
```

- 记得释放

```kotlin
mediaPlayer.stop()
mediaPlayer.release()
videoView.suspend()
```

## 视频编码

- 空间冗余,时间冗余,感知冗余
- 编码格式
  - H264/AVC
  - H265/HEVC(High Efficiency Video Coding)
- 封装格式,与编码格式无关
  - MP4，AVI，FLV，RMVB

### I/B/P帧

https://www.cnblogs.com/yongdaimi/p/10676309.html

![img](/images/653161-20211216165707365-1947946625.png)

```
     I P B B P B B
DTS(Decoding Time Stamp)：1 2 3 4 5 6 7
PTS(Presentation Time Stamp)：1 4 2 3 7 5 6
```

https://www.jianshu.com/p/1c0ec6eba229
https://blog.csdn.net/stoppig/article/details/23198809

# Picture

### 色彩空间

- ARGB_8888
- YUV/YCrCb(Luma & Chroma)
  - 亮度采样与色彩采样

![image-20221203214719024](/images/image-20221203214719024.png)

### 图片格式

- 位图
- JPEG全称Joint Photographic Experts Group     有损压缩⽅案
  - 去除冗余的图像和彩⾊数据 
  - 压缩⽐相对较⾼，⽂件⼤⼩相对较⼩
  - 不⽀持透明图和动态图
- PNG格式，全称Portable Network Graphics
  - ⾼压缩⽐的⽆损压缩，⽂件⼤⼩⽐jpeg⾼些
- WebP是⾕歌提供的⼀种⽀持有损压缩和⽆损压缩的图⽚⽂件格式
  - ⽐JPEG或PNG更好的压缩


## 图片处理

```
decodeFile(String pathName, Options opts) // 从本地⽂件中加载 
decodeResource(Resources res, int id, Options opts) // 从apk的资源中加载 
decodeStream(InputStream is, Rect outPadding, Options opts) // 输⼊流中加载 
decodeByteArray(byte[] data, int offset, int length) // 字节数组中加载
```

```java
//加载超⼤图⽚
BitmapFactory.Options options = new BitmapFactory.Options(); 
// inJustDecodeBounds为true，不返回bitmap，只返回这个bitmap的尺⼨ 
options.inJustDecodeBounds = true; 
BitmapFactory.decodeResource(getResources(), image, options);
// 利⽤返回的原图⽚的宽⾼，我们就可以计算出缩放⽐inSampleSize(只能是2的整数次幂) 
options.inSampleSize = calculateInSampleSize(options, reqWidth, reqHeight); options.inPreferredConfig = Bitmap.Config.RGB_565; //使⽤RGB_565减少图⽚⼤⼩ //inJustDecodeBounds为false，返回bitmap 
options.inJustDecodeBounds = false; 
Bitmap bitmap = BitmapFactory.decodeResource(getResources(), image, options);
canvas.drawBitmap(bitmap, 0, 0, null);
```

### 图片库

<img src="/images/image-20221203212723749.png" alt="image-20221203212723749" style="zoom: 50%;" />

![image-20221203213536481](/images/image-20221203213536481.png)

```kotlin
val targetWidth=viewWidth.toFloat()
        val targetHeight=viewHeight.toFloat()
        if (item.imageName.isNotEmpty()){
            if (viewWidth!=-1&&viewHeight!=-1){
                val width = item.imageWidth.toFloat()
                val height = item. imageHeight.toFloat()
                var inSampleSize = 1f
                if (height > targetHeight || width > targetHeight) {
                    inSampleSize = if (width > height) {
                        (width / targetWidth)
                    } else {
                        (height / targetHeight)
                    }
                }
                val resultWidth = (width/inSampleSize).toInt()
                val resultHeight = (height/inSampleSize).toInt()

                Glide.with(activity)
                    .load("http://192.168.0.184:8080/images/${item.imageName}")
                    .apply(RequestOptions().override(resultWidth, resultHeight))
                    .into(imageView)
            }else{
                Glide.with(activity)
                    .load("http://192.168.0.184:8080/images/${item.imageName}")
                    .into(imageView)
            }

        }
```

### 图⽚缓存策略

<img src="/images/image-20221203213752583.png" alt="image-20221203213752583" style="zoom:50%;" />