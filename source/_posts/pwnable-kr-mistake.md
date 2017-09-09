---
title: 'pwnable.kr #mistake'
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2017-06-06 14:50:21
categories:
	- Writeups
	- pwnable.kr
thumbnailImage: pwnablekr.jpg
keywords:
    - pwnable.kr
    - Toddler's Bottle
    - mistake
tags:
    - Writeups
---
C語言又再度讓我驚豔！
<!-- more -->
題目給的提示是關於運算元的優先等級，還說這題不要太認真，不需要高深的技巧XD。

連入解題主機後有這些檔案：
```
mistake@ubuntu:~$ ls
flag  mistake  mistake.c  password
```

`mistake.c`的原始碼：
```c
#include <stdio.h>
#include <fcntl.h>

#define PW_LEN 10
#define XORKEY 1

void xor(char* s, int len){
	int i;
	for(i=0; i<len; i++){
		s[i] ^= XORKEY;
	}
}

int main(int argc, char* argv[]){

	int fd;
	if(fd=open("/home/mistake/password",O_RDONLY,0400) < 0){
		printf("can't open password %d\n", fd);
		return 0;
	}

	printf("do not bruteforce...\n");
	sleep(time(0)%20);

	char pw_buf[PW_LEN+1];
	int len;
	if(!(len=read(fd,pw_buf,PW_LEN) > 0)){
		printf("read error\n");
		close(fd);
		return 0;
	}

	char pw_buf2[PW_LEN+1];
	printf("input password : ");
	scanf("%10s", pw_buf2);

	// xor your input
	xor(pw_buf2, 10);

	if(!strncmp(pw_buf, pw_buf2, PW_LEN)){
		printf("Password OK\n");
		system("/bin/cat flag\n");
	}
	else{
		printf("Wrong Password\n");
	}

	close(fd);
	return 0;
}
```

既然題目已經說跟運算元有關，馬上把焦點放在第17行`fd=open("/home/mistake/password",O_RDONLY,0400) < 0`，這滿有趣的，仔細思考一下，先是進行了開檔的動作，若檔案存在成功開檔，會回傳`1`，再來因為`<`的優先等級比`=`高，所以會先進行比較，最終`fd`會得到`1 < 0`的比較結果是`0`。

下一個焦點放在第27行，經過剛才開檔的動作以後，此時`fd = 0`，根據`read()`函式的定義，`fd`值為`0`時，會從標準輸入（stdin）讀入資料，可以讓我們輸入`pw_buf`的值，不過根據後面真正讀入`pw_buf2`密碼的第35行，密碼長度應該有10位數，而且`pw_buf2`會進行`XOR`運算，根據這些條件我們便可以輸入`0000000000`給`pw_buf`，`1111111111`給`pw_buf2`來滿足第40行的密碼判斷便可以拿到flag。
```
mistake@ubuntu:~$ ./mistake
do not bruteforce...
0000000000
input password : 1111111111
Password OK
Mommy, the operator priority always confuses me :(
```

真的是一題有趣的題目，的確是平常在寫程式時可能會忽略的小細節，造就了不一樣的結果。