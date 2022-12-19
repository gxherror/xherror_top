---
title: "安卓动画"
description: 学习
date: 2022-12-19T05:31:04Z
image: 
math: 
license: 
hidden: false
comments: true
categories:
 - ANDROID
tags:
---
## 视图动画/补间动画:android.view.animation

• 只能对 View 做动画
• 只能对 View 的某些绘制属性做动画
• 只是视觉效果

```java
//绑定监听事件
mRotateAnimation.setAnimationListener(new Animation.AnimationListener() {
    @Override
    public void onAnimationStart(Animation animation) {
        Log.i(getLogTag(), "onAnimationStart");
    }

    @Override
    public void onAnimationEnd(Animation animation) {
        Log.i(getLogTag(), "onAnimationEnd");
    }

    @Override
    public void onAnimationRepeat(Animation animation) {
        Log.i(getLogTag(), "onAnimationRepeat");
    }
});
```

```java
//java实现，灵活
RotateAnimation rotateAnimation = new RotateAnimation(
0, 360,
Animation.RELATIVE_TO_SELF, 0.5f,
Animation.RELATIVE_TO_SELF, 0.5f);
rotateAnimation.setDuration(1000);
mImage.startAnimation(rotateAnimation);

```

```xml
//xml实现，复用
<!-- anim/rotate.xml -->
<set xmlns:android="http://schemas.android.com/apk/res/android" >
<rotate
android:duration="1000"
android:fromDegrees="0"
android:interpolator="@android:anim/accelerate_decelerate_interpolator"
android:pivotX="50%"
android:pivotY="50%"
android:toDegrees="+360" />
</set>
loadAnimation = AnimationUtils.loadAnimation(this, R.anim.rotate);
mImage.startAnimation(loadAnimation);
```

```java
//注意动画启动与销毁
private RotateAnimation mRotateAnimation;
@Override
public void onResume() {
    super.onResume();
    initAnimation();
    if (null != mRobot) {
        mRobot.startAnimation(mRotateAnimation);
    }
}
@Override
public void onPause() {
    super.onPause();
    if(null != mRotateAnimation && mRotateAnimation.hasStarted()) {
        mRotateAnimation.cancel();
    }
}
```

### AnimationSet

Represents a group of Animations that should be played together. 

## 属性动画:android.animation

```java
//配置Animator
public static ObjectAnimator ofFloat(
Object target,
String propertyName,
float... values
) {
    ObjectAnimator anim = new ObjectAnimator(target, propertyName);
    anim.setFloatValues(values);
    return anim;
}
//调用
ObjectAnimator animator = ObjectAnimator.ofFloat(findViewById(R.id.image_view),
"rotation", 0, 360);
animator.setRepeatCount(ValueAnimator.INFINITE);
animator.setInterpolator(new LinearInterpolator());
animator.setDuration(8000);
animator.setRepeatMode(ValueAnimator.RESTART);
animator.start();
```

```xml
//xml配置
<!-- animator/rotate.xml -->
<objectAnimator xmlns:android="http://schemas.android.com/apk/res/android"
android:duration="8000"
android:propertyName="rotation"
android:interpolator="@android:anim/linear_interpolator"
android:repeatCount="infinite"
android:repeatMode="restart"
android:valueFrom="0"
android:valueTo="360" />

// RotationPropertyActivity.java
Animator animator = AnimatorInflater.loadAnimator(this, R.animator.rotate);
animator.setTarget(findViewById(R.id.image_view));
animator.start();
```

### AnimatorSet

```java
AnimatorSet setAnimation = new AnimatorSet();
// 示例1
setAnimation.play(translateAnimation).after(alphaAnimation).before(rotateAnimation);
setAnimation.play(rotateAnimation).before(scaleAnimation);
//示例2
setAnimation.playSequentially(alphaAnimation, translateAnimation, rotateAnimation, scaleAnimation);
//示例3
setAnimation.playTogether(alphaAnimation, translateAnimation, rotateAnimation, scaleAnimation);
```

![image-20221029142136037](/images/image-20221029142136037.png)

![image-20221029143209272](/images/image-20221029143209272.png)

### Activity 切换动画

```java
// 进⼊动画
startActivity(new Intent(TransitionActivity.this, TransitionActivity.class));
overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
// 退出动画
super.finish();
overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
```



## 逐帧动画/drawable动画

- 逐帧动画会⼀次性将所有图⽚加载到内存中，会有OOM⻛险

```xml
// res/drawable/anim_list.xml
<animation-list xmlns:android="http://schemas.android.com/apk/res/android" >
<item android:drawable="@drawable/one" android:duration="500"/>
<item android:drawable="@drawable/two" android:duration="500"/>
<item android:drawable="@drawable/three" android:duration="500"/>
<item android:drawable="@drawable/four" android:duration="500"/>
</animation-list>
// activity
mImage = findViewById(R.id.image_frame);
mImage.setBackgroundResource(R.drawable.anim_list);
AnimationDrawable drawable = (AnimationDrawable) mImage.getBackground();
drawable.start();
```

## Lottie

```xml
dependencies {
// app/build.gradle 添加依赖
implementation ‘com.airbnb.android:lottie:3.4.2'
}
<com.airbnb.lottie.LottieAnimationView
android:id="@+id/lottieView"
android:layout_width="200dp"
android:layout_height="200dp"
android:layout_gravity="center"
app:lottie_rawRes="@raw/lottie_raw_rocket"
app:lottie_autoPlay="true"
app:lottie_loop="true"/>
```

![image-20221029143222044](/images/image-20221029143222044.png)