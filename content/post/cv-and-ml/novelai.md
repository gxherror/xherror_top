---
title: "Novelai"
description: 
date: 2022-10-22T13:02:05Z
image: 
math: 
license: 
hidden: false
comments: true
categories:
    - CV_ML
tags:
---
# 平台colab/kaggle

- 都需要科学上网
- 建议通过google帐号注册

## kaggle

每周可白嫖40h左右

https://www.kaggle.com/code

1.在右侧找到settings，打开网络

如果没有这一选项，有一行小字提醒需要进行**手机认证**，否则无法正常使用

![image-20221022203238368](images/image-20221022203238368.png)

2.复制`ipynb`到code块，选择GPU

![image-20221022203333781](images/image-20221022203333781.png)

3. 在右侧settings，accelerator可以看见剩余时长



![image-20221022185529987](images/image-20221022185529987.png)

4. 要退出时记得在右下角关闭session，

![image-20221022203926887](images/image-20221022203926887.png)

## colab

只能等到有GPU时才能使用，通常下午时刻空闲GPU比较多

https://colab.research.google.com/

1.选择runtime中的runtime type

![01432fdd6bb431251fb901aa38d09d9c.png](images/01432fdd6bb431251fb901aa38d09d9c.png)

2. 选择GPU

![0dbeda6b0b98eaf26bc121d710fb25e4.png](images/0dbeda6b0b98eaf26bc121d710fb25e4.png)

3. 无空闲GPU提示

![image-20221022204419754](images/20221022204419754.png)

4. 复制ipynb，运行

## ipynb

```python
# 仅Colab使用，kaggle删除下面两行
import os
os.kill(os.getpid(), 9)

# clone webui前端
!git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui
%cd stable-diffusion-webui

# 获取novelai的训练权重文件与超参数
!curl -Lo  models/Stable-diffusion/model.ckpt https://cloudflare-ipfs.com/ipfs/bafybeicpamreyp2bsocyk3hpxr7ixb2g2rnrequub3j2ahrkdxbvfbvjc4/model.ckpt

!curl -Lo models/Stable-diffusion/animefull-final-pruned.vae.pt https://cloudflare-ipfs.com/ipfs/bafybeiccldswdd3wvg57jhclcq53lvsc6gizasiblwayvhlv6eq4wow7wu/animevae.pt 

!mkdir models/hypernetworks

!curl -Lo models/hypernetworks/_modules.tar  https://cloudflare-ipfs.com/ipfs/bafybeiduanx2b3mcvxlwr66igcwnpfmk3nc3qgxlpwh6oq6m6pxii3f77e/_modules.tar 

!tar -xf models/hypernetworks/_modules.tar -C models/hypernetworks/

# 安装依赖环境
!COMMANDLINE_ARGS="--exit " REQS_FILE="requirements.txt"  python launch.py

# 获取最新版webui
%cd stable-diffusion-webui
!git pull

# 启动
!COMMANDLINE_ARGS=" --share --disable-safe-unpickle -gradio-debug --gradio-auth me:qwerty" REQS_FILE="requirements.txt" python launch.py
```

# 设置

用过生成的public URI打开网站，默认帐号:me,密码：qwerty

1. 加载权重文件

![326bfce5a179b5fbd782e6f08e9873f8.png](images/326bfce5a179b5fbd782e6f08e9873f8.png)

2.忽略 CLIP 模型的最后一层：2

![image-20221022192117575](images/image-20221022192117575.png)

3. 设置种子噪声

![image-20221022192127875](images/image-20221022192127875.png)

4. 应用修改，在最上面

![image-20221022204949282](images/image-20221022204949282.png)

## 转换

```
NovelAI官网使用的加重权重用的是 { } ，削减用的是[ ]，{ }具体表示提升1.05倍权重，[ ]则是降低1.05倍。

但是在WebUI中，我们不使用{ }，而是使用( )，且我们的( )提升的权重为1.1倍。 
```

```python
        tokens_with_parens = [(k, v) for k, v in self.tokenizer.get_vocab().items() if '(' in k or ')' in k or '[' in k or ']' in k]
        for text, ident in tokens_with_parens:
            mult = 1.0
            for c in text:
                if c == '[':
                    mult /= 1.1
                if c == ']':
                    mult *= 1.1
                if c == '(':
                    mult *= 1.1
                if c == ')':
                    mult /= 1.1
```

通过修改prompt

```
{masterpiece}=(masterpiece:1.05)

{{masterpiece}}=(masterpiece:1.1025)怎么算的？(1.1025 = 1*1.05*1.05)

[masterpiece]=(masterpiece:0.952)怎么算的？(0.952 = 1/1.05)

[[masterpiece]]=(masterpiece:0.907)怎么算的？(0.907 = 1/1.05/1.05) 
```

或者是直接修改`stable-diffusion-webui/modules/sd_hijack.py`的代码

## 验证

```
best quality, masterpiece, asuka langley sitting cross legged on a chair
Negative prompt: lowres, bad anatomy, bad hands, text, error, missing fingers, extra digit, fewer digits, cropped, worst quality, low quality, normal quality, jpeg artifacts,signature, watermark, username, blurry, artist name
Steps: 28, Sampler: Euler, CFG scale: 12, Seed: 2870305590, Size: 512x512, Model hash: 925997e9, Clip skip: 2, ENSD: 31337
```

![image-20221022193351854](images/image-20221022193351854.png)

# 参考

https://github.com/JingShing/novelai-colab-ver/blob/main/StableDiffusionUI_(adapted_to_NovelAILeaks).ipynb

https://www.bilibili.com/read/cv19113199?from=articleDetail

https://github.com/AUTOMATIC1111/stable-diffusion-webui/discussions/2017

https://www.bilibili.com/read/cv19174240