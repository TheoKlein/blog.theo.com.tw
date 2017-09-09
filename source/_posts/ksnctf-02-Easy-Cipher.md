---
title: 'ksnctf #02 Easy Cipher'
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2016-12-04 23:39:14
categories:
	- Writeups
	- ksnctf
thumbnailImage: ksnctf.png
keywords:
    - ksnctf
    - Easy Chiper
tags:
    - Writeups
---
直接給了一段密文
{% blockquote %}
EBG KVVV vf n fvzcyr yrggre fhofgvghgvba pvcure gung ercynprf n yrggre jvgu gur yrggre KVVV yrggref nsgre vg va gur nycunorg. EBG KVVV vf na rknzcyr bs gur Pnrfne pvcure, qrirybcrq va napvrag Ebzr. Synt vf SYNTFjmtkOWFNZdjkkNH. Vafreg na haqrefpber vzzrqvngryl nsgre SYNT.
{% endblockquote %}
<!-- more -->

我第一次看到這題的時候其實一直看不出什麼端倪，看到Cipher這個關鍵字我只想到了之前遇過的[凱薩加密法](https://zh.wikipedia.org/wiki/%E5%87%B1%E6%92%92%E5%AF%86%E7%A2%BC)，寫了一個小程式去試所有的位移可能也沒看到什麼結果。

過了幾天再回來看才忽然注意到其中這一串字：
{% blockquote %}
SYNTFjmtkOWFNZdjkkNH
{% endblockquote %}

ksnctf flag的形式是```FLAG_123456xyz```，整串密文中只有這字一串的長度夠長、開頭都是大寫而且前四個字母沒有重複，用FLAG這四個字去分析了一下還真的發現有規律，查了一下資料後得知這是所謂的[ROT-13](https://zh.wikipedia.org/wiki/ROT13)，一種簡易的替換式密碼。

知道加密方法就好辦事了，ROT-13屬於對等加密（reciprocal cipher），所以只要把密文再使用ROT-13加密一次即可回復原始文字。簡單的PHP程式就可以解密：
{% codeblock lang:php %}
<?php
echo str_rot13("EBG KVVV vf n fvzcyr yrggre fhofgvghgvba pvcure gung ercynprf n yrggre jvgu gur yrggre KVVV yrggref nsgre vg va gur nycunorg. EBG KVVV vf na rknzcyr bs gur Pnrfne pvcure, qrirybcrq va napvrag Ebzr. Synt vf SYNTFjmtkOWFNZdjkkNH. Vafreg na haqrefpber vzzrqvngryl nsgre SYNT.");
{% endcodeblock %}

{% blockquote %}
ROT XIII is a simple letter substitution cipher that replaces a letter with the letter XIII letters after it in the alphabet. ROT XIII is an example of the Caesar cipher, developed in ancient Rome. Flag is FLAGSwzgxBJSAMqwxxAU. Insert an underscore immediately after FLAG.
{% endblockquote %}

網路上也有現成的[rot13.com](http://www.rot13.com)可以直接ROT-13轉換。

看到FLAG別太興奮直接複製提交，在FLAG後面還要自己再加個底線才符合```FLAG_123456xyz```的形式，密文的最後一句話有貼心的提醒XD。

~~我絕對不是那個看到FLAG太興奮就直接複製貼上結果Wrong Flag在電腦前面煩惱的人~~