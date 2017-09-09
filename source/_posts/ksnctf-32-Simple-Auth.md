---
title: 'ksnctf #32 Simple Auth'
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2017-03-22 20:56:23
categories:
	- Writeups
	- ksnctf
thumbnailImage: ksnctf.png
keywords:
    - ksnctf
    - Simple Auth
tags:
    - Writeups
---
出乎意料之外的PHP strcasecmp() bug
<!-- more -->

source code可以看到非常簡單僅有6行的PHP程式碼，只從POST表單取得password的值進行strcasecmp()。在我搜尋相關資料的期間看到了這一篇[bug report](https://bugs.php.net/bug.php?id=64069)，傳入一個array竟然會使strcasecmp()不是回傳數字而是一個NULL，那麼這題就在簡單不過了...

{% codeblock lang:curl %}
curl -X POST -F ' password[]="" ' http://ctfq.sweetduet.info:10080/~q32/auth.php
{% endcodeblock %}