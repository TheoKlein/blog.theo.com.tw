---
title: 'TMCTF 2017 #Reverse 100'
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2017-06-25 00:21:19
categories:
	- Writeups
	- TMCTF2017
thumbnailImage: cover.jpg
keywords:
    - TMCTF2017
    - Reverse 100
tags:
    - Writeups
    - TMCTF
---
總算開始有解題的感覺了 OAO
<!-- more -->

## 前情提要

雖然這次TMCTF最後還是0題收場，Reverse 100這題就卡在最後一個檔案反組譯還不熟悉找不到flag片段，雖然差一點點就破蛋了感覺頗漚，但這次關於Reverse 100還是學習了一些經驗。

## 正文
題目非常簡潔扼要：
> You get one unknown file. Please find flag in this file with your knowledge.

給了`pocket`這個檔案，既然unknown，那就來看看它的檔案型態。

```
$ file pocket
pocket: Zip archive data, at least v2.0 to extract
```

既然是壓縮檔，加上副檔名後解壓縮拿到`biscuit`這個同樣也是未知的檔案，相同方式再看一次：

```
$ file biscuit
biscuit: RAR archive data, v1d, os: Win32
```

又是壓縮檔（這時候心裡開始OS該不會是多層壓縮檔吧），在解壓縮一次，這次開始有所不同了，得到了`biscuit1`和`biscuit2`兩個檔案。

```
$ file biscuit1 biscuit2
biscuit1: PE32 executable (console) Intel 80386 (stripped to external PDB), for MS Windows
biscuit2: Zip archive data, at least v2.0 to extract
```

`biscuit1`是 Windows 的執行檔，`biscuit2`又是個壓縮檔，不過這個解壓縮需要密碼，所以只好再把焦點放回`biscuit1`上。

![](biscuit1.png)

執行以後看來要我們找`m`開頭的單字來解壓縮`biscuit2`，看來得反組譯看看了，問題我自己也還是反組譯的超級新手，抱著沒什麼太大的期望打開了[Immunity Debugger](https://www.immunityinc.com/products/debugger/)開始到處看看，想說已知要找`m`開頭的單字的話或許可以看到什麼蛛絲馬跡，花點時間找了找還真的在stack裡面看到了`macaron`，真是幸運，詳細的組合語言反組譯之後在花點時間去仔細研究看看。（本來就該trace組語才對啊啊啊）

![](stack.png)

這邊拿到密碼就先解壓縮再說，再拿到`biscuit3`、`biscuit4`、`biscuit5`三個檔案

```
$ file biscuit3 biscuit4 biscuit5
biscuit3: JPEG image data, JFIF standard 1.01, aspect ratio, density 1x1, segment length 16, comment: "Optimized by JPEGmini 3.13.3.15 0x411b5876", baseline, precision 8, 150x150, frames 3
biscuit4: ASCII text, with CRLF line terminators
biscuit5: PE32 executable (console) Intel 80386 (stripped to external PDB), for MS Windows
```

`biscuit4`是個文字檔，提示說`Flag = TMCTF{biscuit3_ biscuit5}`。

接著看`biscuit3` ：

![](biscuit3.jpg)

恩...一盤餅乾...
當然不能只單純看圖片是什麼，要檢查檔案本身有沒有被塞其他東西。我用[binwalk](https://github.com/devttys0/binwalk)來檢查：
```
$ binwalk biscuit3.jpg

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             JPEG image data, JFIF standard 1.01
382           0x17E           Copyright string: "Copyright (c) 1998 Hewlett-Packard Company"
14253         0x37AD          Zip archive data, at least v1.0 to extract, compressed size: 5, uncompressed size: 5, name: biscuit.txt
14356         0x3814          End of Zip archive
```

果然在最後`14253`開始的地方又藏了一個壓縮檔在裡面，利用`dd`指令把這個壓縮檔分離出來：

```
$ dd if=biscuit3.jpg bs=1 skip=14253 of=biscuit3.zip
```

解壓縮後是一個純文字檔，終於拿到`biscuit3`的flag片段：`cream`。

最後一個拼圖`biscuit5`又是個 Windows 執行檔，這次執行後沒有輸出任何提示，只好再次丟到[Immunity Debugger](https://www.immunityinc.com/products/debugger/)想辦法找找線索。剛剛用偷吃步的報應現在馬上就踢到鐵板了，還不太會trace組語的我看了老半天實在是找不到什麼特別的字串。最後就卡在這裡解不出來...

比賽結束後看了其他人的writeup才注意到trace組語的一些技巧，原來程式大概的實作內容是原先有`biscu`5個字的字串，會進入迴圈開始做替換的動作，仔細一步一步觀察迴圈做的動作，最後就會得知替換完的字串是`choux`，相見恨晚啊！這題到這邊就可以把flag湊齊了。

## 結論
反組譯還是要好好練，該看的組語還是要看（切身之痛 QQ
找時間再研究IDA的用法，常看到大家搭配IDA來檢視程式運作的流程，比起直接看全部的組語更可以快速掌握一些程式的關鍵點。