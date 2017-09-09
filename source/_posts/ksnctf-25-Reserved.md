---
title: 'ksnctf #25 Reserved'
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2017-03-23 18:25:36
categories:
	- Writeups
	- ksnctf
thumbnailImage: ksnctf.png
keywords:
    - ksnctf
    - Simple Auth II
tags:
    - Writeups
---
這題靠的是經驗
<!-- more -->

忘記之前是在哪裡看到了，一看到開頭`length q...`就想到是[ppencode](http://namazu.org/~takesako/ppencode/demo.html)，一種perl的代碼混淆，都說是混淆了所以當然還是可以執行，複製下來執行就會看到flag了。

{% codeblock %}
$ perl q25.pl
FLAG_As5zgVSNukaoJvvZ    Thank you, ppencode.
{% endcodeblock %}