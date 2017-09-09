---
title: 'pwnable.kr #fd'
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2017-06-04 17:48:11
categories:
	- Writeups
	- pwnable.kr
thumbnailImage: pwnablekr.jpg
keywords:
    - pwnable.kr
    - Toddler's Bottle
    - fd
tags:
    - Writeups
---
開始踏上pwn之路了
<!-- more -->

依照題目給的SSH資訊進入主機以後，目錄底下有這些檔案：
```
fd@ubuntu:~$ ls -al
total 40
drwxr-x---  5 root   fd   4096 Oct 26  2016 .
drwxr-xr-x 80 root   root 4096 Jan 11 23:27 ..
d---------  2 root   root 4096 Jun 12  2014 .bash_history
-r-sr-x---  1 fd_pwn fd   7322 Jun 11  2014 fd
-rw-r--r--  1 root   root  418 Jun 11  2014 fd.c
-r--r-----  1 fd_pwn root   50 Jun 11  2014 flag
-rw-------  1 root   root  128 Oct 26  2016 .gdb_history
dr-xr-xr-x  2 root   root 4096 Dec 19 01:23 .irssi
drwxr-xr-x  2 root   root 4096 Oct 23  2016 .pwntools-cache
```

分析`fd.c`的原始碼：
```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
char buf[32];
int main(int argc, char* argv[], char* envp[]){
	if(argc<2){
		printf("pass argv[1] a number\n");
		return 0;
	}
	int fd = atoi( argv[1] ) - 0x1234;
	int len = 0;
	len = read(fd, buf, 32);
	if(!strcmp("LETMEWIN\n", buf)){
		printf("good job :)\n");
		system("/bin/cat flag");
		exit(0);
	}
	printf("learn about Linux file IO\n");
	return 0;

}
```

很簡單的一個C程式，首先6~9行的if判斷有無輸入argv參數，將其值減去`0x1234 (4660)`以後存為`fd`的變數代入`read`函式，該函式的定義如下：
```
ssize_t read(int fildes, void *buf, size_t nbytes);

int fildes
   * 0: standard input
   * 1: standard output
   * 2: standard error
```

所以我們可以輸入4660作為argv參數讓`fd = 0`進而使`read`函式從標準輸入讀取我們輸入的`LETMEWIN`字串便可以拿到flag。
```
fd@ubuntu:~$ ./fd 4660
LETMEWIN
good job :)
mommy! I think I know what a file descriptor is!!
```