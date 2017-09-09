---
title: 'pwnable.kr #random'
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2017-06-26 20:06:42
categories:
	- Writeups
	- pwnable.kr
thumbnailImage: pwnablekr.jpg
keywords:
    - pwnable.kr
    - Toddler's Bottle
    - random
tags:
    - Writeups
---
電腦沒有真正的亂數
<!-- more -->
很簡單的一個C亂數程式：
```c
#include <stdio.h>

int main(){
	unsigned int random;
	random = rand();	// random value!

	unsigned int key=0;
	scanf("%d", &key);

	if( (key ^ random) == 0xdeadbeef ){
		printf("Good!\n");
		system("/bin/cat flag");
		return 0;
	}

	printf("Wrong, maybe you should try 2^32 cases.\n");
	return 0;
}
```

只要輸入的值和隨機數做`XOR`運算後等於`0xdeadbeef`就可以拿到flag，關鍵就在`rand()`產生的隨機數。電腦沒有真正的亂數，是由數學計算出來接近亂數的值，也就是說它有一連串的公式計算，平常都知道若要讓亂數能夠更亂（某意義上接近真正的亂數），C語言必須指定`seed`，也就是亂數種子，通常會是時間。

很明顯這個程式並沒有設定種子，換句話說產生出來的亂數會永遠一樣，那我們就可以自己寫程式來印出`rand()`的第一個值`1804289383`。接下來`XOR`的運算有這樣的特性：
```
A ^ B = C
A = B ^ C
```

所以只要把第一個亂數值`1804289383`和`0xdeadbeef`做`XOR`運算就可以得到`key`。我用python CLI直接算出`key`：
```
>>> print 0xdeadbeef ^ 1804289383
3039230856
```

```
random@ubuntu:~$ ./random
3039230856
Good!
Mommy, I thought libc random is unpredictable...
```