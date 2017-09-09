---
title: 'ksnctf #14 John'
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2017-06-03 17:52:09
categories:
	- Writeups
	- ksnctf
thumbnailImage: ksnctf.png
keywords:
    - ksnctf
    - John
tags:
    - Writeups
---
簡單練習John的操作
<!-- more -->
標題就清楚寫明是關於[John](http://www.openwall.com/john/)的問題，題目給了shadow的內容：
```
user00:$6$Z4xEy/1KTCW.rz$Yxkc8XkscDusGWKan621H4eaPRjHc1bkXDjyFtcTtgxzlxvuPiE1rnqdQVO1lYgNOzg72FU95RQut93JF6Deo/:15491:0:99999:7:::
user01:$6$ffl1bXDBqKUiD$PoXP69PaxTTX.cgzYS6Tlj7UBvstr6JruGctoObFXCr4cYXjIbxBSMiQZiVkKvUxXUC23zP8PUyXjq6qEq63u1:15491:0:99999:7:::
user02:$6$ZsJXadT/rv$T/2gVzYwMBaAsZnHIjnUSmTozIF/ebMvtHIJjikFehvB8pvy28DUIQYbTJLG6QAxhzJAKOROnZq0xV4hUGefM1:15491:0:99999:7:::
user03:$6$l0NHH5FF0H/U$fPv3c5Cdls/UaZmglR4Qqh8vhpIBsmY1sEjHi486ZcDQ2Vx5GY0fcQYSorWj6l42jfI47w437n.NBm8NArFyT/:15491:0:99999:7:::
user04:$6$wAnAP/NMiLa/yE$.gi4r3xYuPTg5z2S59z2EzFbqpmwZYy1tBSVA9/hqTFnWY0tHqXbwL.dFQwHzKTuzXV6WMgjEZlyzUPGzVtPb0:15491:0:99999:7:::
user05:$6$jTgFhKHk/$xQIdn7snYAAGvifxC02YLXcAKkiuPbJ3KBkH2Q8BZ12TL2aepaUJotgfKfNSPCXWebyCY/skOmOymok.KIm5D0:15491:0:99999:7:::
user06:$6$8LXZt/zPbLtIn1o$ynsZxueG88Kz0vDr3cyK.21cv4GWw9iaW9oYZcmZ9SY5UpMQS1wl2/dbXGyR8WzVBKKP/6k8VYvWuiNQ3We52/:15491:0:99999:7:::
user07:$6$jnA8m/S5aU0/$PGrG8mDy.vs3W9xhG1qd56eOEainH9xntY48.duznt989TXMn6J.scOBqp4BWg3fHWxoFgBn26LYvcnqWGcoF1:15491:0:99999:7:::
user08:$6$ITB7n/qsP$fmrmItHX9B96PmhsxIX21vdYDvFHiIPnyzRFjWIbcd3y/DRHCm0lzyJEnWlQChdDAiFUFXtqwoTbEdREXQ99M.:15491:0:99999:7:::
user09:$6$LpgLJrjPV$6sa0KW08Q10S.C/BSUHlHaQZT5n8uIygZSsWP5drdmuhI7c17wWCK/GEzQS7g8EL//5bqdjo1C90smTDhLEcF1:15491:0:99999:7:::
user10:$6$0VSPwOzcL//6QR$RgtMpkfVPb5Cli7cjVE5jMgJlN10xY1R3jxRNrY0l/84R3.NvxP3I8XtkMkonU6DKhge0JGp54DZLQqUN9kL7/:15491:0:99999:7:::
user11:$6$zryub/lvSKj7Xl$eazV2fmcJa5M3qMovQqARGK59Qxtfv2zjUJvphKNnyUMVyBn.SjEFhRT/mAjz3QFroNbwmrYLtrpyxjH.q64n/:15491:0:99999:7:::
user12:$6$tAkM0dDUFe76d8K/$OnNGFEuIf1seMlLHb.8.y5/cpmBUcMbhLhOfFdd0E/DKASXPS4riB4uz2Fg3om9Atg.g7s.JFoKV0uuJ461KV/:15491:0:99999:7:::
user13:$6$0cCdE5Nfqu/HFS$PwnLdS.chtm6qGwf2Uuiko7V3fMwjcQ52M8hslvoReFQ9XOBXw603Ok20VJwWAwR6RNv6adn6a6kuRm5Y3.ge1:15491:0:99999:7:::
user14:$6$RgPs7j4eSa/v$71CeLB9Z1Fafi6vi2ou5LzRz5xXWTzvZeZgelnm2przx.JQYp21p8h2BCyTYFd10MKD/cquPvn42vSzlJJJ8Q1:15491:0:99999:7:::
user15:$6$1uhGQ/5DwMp/$UjYTEVaChEzmUITvWpaZVvYYDLBULpI4IEyieClSsyC2NHwEnaDx6xwtUVpQPxEhi6R7OQhX68Oo5CfilYqDQ.:15491:0:99999:7:::
user16:$6$V/InSacMp8U$UpDgdL/GS/kdFmn1rO97YkLAeTgofu4fDVUGoV1PWnVFxUtVyx24ix5hJp53FkBuqdzmXgwGcb6MU5AWJWjaB1:15491:0:99999:7:::
user17:$6$d6mWSrE8vxDe$UqTgKPfKxm0/Aboz8DeFNNiZsFBYyE6iGpqUzSX4UpWSDfXt1DERBtI29H2Gz5q.6ls3730naAo31wAacvs/L0:15491:0:99999:7:::
user18:$6$ulcKu/ddomcNGRJj$i8XB1D4YtLGbAHX0XHX88ObUWw8dQsrTqoliGAU//zGHNLmLeWd.4k5YHViNSy3rlGTQSRPtutlKnub8aRnzy0:15491:0:99999:7:::
user19:$6$cVnhE9CwfSIIA$wrn6p3cgfz.JOc6KVkieNCtc.FzkjUdcDDlivn0APnYv9/z4tt7hUpPft5T8kMmnx/hiF92vjnDxcauVyQySp.:15491:0:99999:7:::
user20:$6$2Pg2VxXg$K8AqsCMPAFiXSxNjETBWqEHQom9Q5dDIz9/nItxpQatrG9gvv9CRJP3kQzKLbRf13FxfOXpeEYIpOEK.2i1HP0:15491:0:99999:7:::
user99:$6$SHA512IsStrong$DictionaryIsHere.http//ksnctf.sweetduet.info/q/14/dicti0nary_8Th64ikELWEsZFrf.txt:15491:0:99999:7:::
```

仔細看了一下，唯獨user99特別不一樣，看起來給了一個字典檔網址：
```
user99:$6$SHA512IsStrong$DictionaryIsHere.http//ksnctf.sweetduet.info/q/14/dicti0nary_8Th64ikELWEsZFrf.txt:15491:0:99999:7:::
```
![Dictionary](dictionary.png)

既然題目有給字典檔想必有它的用處，下載下來給John來破解密碼。
```
$ john --wordlist=dictionary.txt crack.txt
```

`dictionary.txt`是下載下來的字典檔、`crack.txt`是題目給的內容。破解完以後查看結果：
```
$ john --show crack.txt
user00:FREQUENT:15491:0:99999:7:::
user01:LATTER:15491:0:99999:7:::
user02:ADDITIONAL:15491:0:99999:7:::
user03:GENDER:15491:0:99999:7:::
user04:__________:15491:0:99999:7:::
user05:applies:15491:0:99999:7:::
user06:SPIRITS:15491:0:99999:7:::
user07:independent:15491:0:99999:7:::
user08:ultimate:15491:0:99999:7:::
user09:JENNY:15491:0:99999:7:::
user10:HELD:15491:0:99999:7:::
user11:SUFFERS:15491:0:99999:7:::
user12:LEAVE:15491:0:99999:7:::
user13:floating:15491:0:99999:7:::
user14:zecht:15491:0:99999:7:::
user15:opinion:15491:0:99999:7:::
user16:QUESTION:15491:0:99999:7:::
user17:karaoke:15491:0:99999:7:::
user18:strange:15491:0:99999:7:::
user19:zero:15491:0:99999:7:::
user20:DELIGHT:15491:0:99999:7:::
Warning: hash encoding string length 99, type id $6
appears to be unsupported on this system; will not load such hashes.

21 password hashes cracked, 0 left
```

很順利的全部解出來了，重點是要用user99給的字典檔。仔細看每個user密碼的第一個字，原來是藏頭文啊！最後在寫個簡單的程式來拼湊出flag：
```python
# flag.py
flag = ''
for line in open('rawflag.txt', 'r'):
    flag = flag + line[7]
print flag
```

```
$ python flag.py
FLAG_aSiuJHSLfzoQkszD
```

一個簡單的題目來練練John的使用方法。