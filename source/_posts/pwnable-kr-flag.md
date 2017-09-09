---
title: 'pwnable.kr #flag'
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2017-07-13 14:57:45
categories:
	- Writeups
	- pwnable.kr
thumbnailImage: pwnablekr.jpg
keywords:
    - pwnable.kr
    - Toddler's Bottle
    - flag
tags:
    - Writeups
---
Papa brought me a packed present! let's open it.
<!-- more -->
下載下來以後發現是一個ELF檔案
```sh
$ file flag
flag: ELF 64-bit LSB executable, x86-64, version 1 (GNU/Linux), statically linked, stripped
```

我習慣會先看一下hex頭尾的部分，發現除了`ELF`的header以外還有一個[UPX](https://en.wikipedia.org/wiki/UPX)的標記，google才暸解原來是壓縮執行檔的大小，換句話說就像是再次打包，把檔案大小進一步壓縮。
```sh
$ xxd -a flag | head -n 20
00000000: 7f45 4c46 0201 0103 0000 0000 0000 0000  .ELF............
00000010: 0200 3e00 0100 0000 f0a4 4400 0000 0000  ..>.......D.....
00000020: 4000 0000 0000 0000 0000 0000 0000 0000  @...............
00000030: 0000 0000 4000 3800 0200 4000 0000 0000  ....@.8...@.....
00000040: 0100 0000 0500 0000 0000 0000 0000 0000  ................
00000050: 0000 4000 0000 0000 0000 4000 0000 0000  ..@.......@.....
00000060: 04ad 0400 0000 0000 04ad 0400 0000 0000  ................
00000070: 0000 2000 0000 0000 0100 0000 0600 0000  .. .............
00000080: d862 0c00 0000 0000 d862 6c00 0000 0000  .b.......bl.....
00000090: d862 6c00 0000 0000 0000 0000 0000 0000  .bl.............
000000a0: 0000 0000 0000 0000 0000 2000 0000 0000  .......... .....
000000b0: fcac e0a1 5550 5821 1c08 0d16 0000 0000  ....UPX!........
000000c0: 217c 0d00 217c 0d00 9001 0000 9200 0000  !|..!|..........
000000d0: 0800 0000 f7fb 93ff 7f45 4c46 0201 0103  .........ELF....
000000e0: 0002 003e 0001 0e58 1040 1fdf 2fec db40  ...>...X.@../..@
000000f0: 2f78 380c 4526 3800 060a 2100 1f6c 60bf  /x8.E&8...!..l`.
00000100: 1e57 0500 0140 0f5e 110c af7b 6d20 0020  .W...@.^...{m .
00000110: 0b6f 0606 f0b3 07d2 b21e 2f0e 6c00 180d  .o......../.l...
00000120: e82d 7b3b d843 006f 0407 9001 2b0e 40c9  .-{;.C.o....+.@.
00000130: 817c 2044 0000 0476 1b62 db07 17df 204f  .| D...v.b.... O
```

我是用Mac，所以直接用`brew insatll upx`就可以安裝，把剛剛的`flag`解壓縮：
```sh
$ upx -d flag -o de_flag
                       Ultimate Packer for eXecutables
                          Copyright (C) 1996 - 2017
UPX 3.94        Markus Oberhumer, Laszlo Molnar & John Reiser   May 12th 2017

        File size         Ratio      Format      Name
   --------------------   ------   -----------   -----------
    883745 <-    335288   37.94%   linux/amd64   de_flag

Unpacked 1 file.
```

把解壓的`de_flag`丟進IDA Pro分析，看到`main`在`0x0000000000401184`的部分會使用`flag`的變數，點擊`flag`讓IDA Pro直接跳到`.data`的部分就可以看到變數值：

![IDA](ida.png)
```
UPX...? sounds like a delivery service :)
```