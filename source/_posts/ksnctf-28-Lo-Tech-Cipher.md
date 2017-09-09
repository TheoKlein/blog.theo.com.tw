---
title: 'ksnctf #28 Lo-Tech Cipher'
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2017-03-28 14:52:21
categories:
	- Writeups
	- ksnctf
thumbnailImage: ksnctf.png
keywords:
    - ksnctf
    - Lo-Tech Cipher
tags:
    - Writeups
---
這題真的讓我大開眼界
<!-- more -->

題目就給了一個壓縮檔，解壓縮以後有兩張圖片。
![1](1.png)

![2](2.png)

我愣了滿久的，看著這兩張密密麻麻的雜訊，忽然靈光一閃把他們給疊起來看看...
![3](3.png)

{% raw %}Σ(*ﾟдﾟﾉ)ﾉ{% endraw %} 這是什麼妖術！太出乎意料了！
不過FLAG還沒拿到，提示說最後一張圖片在ZIP裡，原來剛剛下載的ZIP是有被動過手腳的，有個好用的`file`指令可以檢查檔案的真實內容。
{% codeblock %}
$ file secret.zip
secret.zip: PNG image data, 640 x 480, 8-bit/color RGBA, non-interlaced
{% endcodeblock %}
沒想到這個ZIP自己就是一個PNG圖片！馬上把副檔名改成`.png`，真的拿到了最後一張圖片，再疊上去就成功拿到FLAG了。
![4](4.png)
這題真的太有趣啦～