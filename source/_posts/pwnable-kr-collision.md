---
title: 'pwnable.kr #collision'
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2017-06-04 18:36:03
categories:
	- Writeups
	- pwnable.kr
thumbnailImage: pwnablekr.jpg
keywords:
    - pwnable.kr
    - Toddler's Bottle
    - collision
tags:
    - Writeups
---
寫CTF的題目總是能讓我對C有更深入的了解
<!-- more -->

SSH進入主機以後，一樣先來看看`col.c`的原始碼：
```c
#include <stdio.h>
#include <string.h>
unsigned long hashcode = 0x21DD09EC;
unsigned long check_password(const char* p){
	int* ip = (int*)p;
	int i;
	int res=0;
	for(i=0; i<5; i++){
		res += ip[i];
	}
	return res;
}

int main(int argc, char* argv[]){
	if(argc<2){
		printf("usage : %s [passcode]\n", argv[0]);
		return 0;
	}
	if(strlen(argv[1]) != 20){
		printf("passcode length should be 20 bytes\n");
		return 0;
	}

	if(hashcode == check_password( argv[1] )){
		system("/bin/cat flag");
		return 0;
	}
	else
		printf("wrong passcode.\n");
	return 0;
}
```

```
col@ubuntu:~$ ./col test
passcode length should be 20 bytes
```

看起來是從argv輸入長度20bytes的密碼來檢驗，把重點放到`check_password(const char* p)`這個函式上，把輸入的字串分成五段加起來要等於`0x21DD09EC`，計算一下，分成五段的話`0x21DD09EC = 0x06C5CEC8 * 4 + 0x06C5CECC`。

為了滿足`check_password`的計算方式，我寫了一個簡單的python exploit。（/tmp底下可以建立資料夾新增自己的檔案）

```python
import struct
print struct.pack('<i', 0x06C5CEC8) * 4 + struct.pack('<i', 0x06C5CECC)
```

因為ubuntu是little-endian system，所以我使用了python的[struct](https://docs.python.org/2/library/struct.html)來輸出little-endian的shell code，`<i`表示`little-endian int`。

```
col@ubuntu:~$ ./col $(python /tmp/theo/col.py)
daddy! I just managed to create a hash collision :)
```