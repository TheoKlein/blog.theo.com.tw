---
title: 'VulnHub #JIS-CTF:VulnUpload'
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2018-05-13 14:30:39
categories:
  - Writeups
  - VulnHub
thumbnailImage: cover.png
keywords:
  - vulnhub
  - writeup
  - JIS-CTF
  - VulnUpload
tags:
  - Writeups
---

Official website: [JIS-CTF: VulnUpload ~ VulnHub](https://www.vulnhub.com/entry/jis-ctf-vulnupload,228/)

<!-- more -->

基本的偵查動作：

```
$ sudo nmap -sP 192.168.31.0/24
Starting Nmap 7.70 ( https://nmap.org ) at 2018-05-13 13:52 CST
...
Nmap scan report for 192.168.31.210
Host is up (0.00043s latency).
MAC Address: 08:00:27:68:18:58 (Oracle VirtualBox virtual NIC)
...
Nmap done: 256 IP addresses (7 hosts up) scanned in 2.17 seconds

$ sudo nmap -A 192.168.31.210
Starting Nmap 7.70 ( https://nmap.org ) at 2018-05-13 13:52 CST
Nmap scan report for 192.168.31.210
Host is up (0.00046s latency).
Not shown: 998 closed ports
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 7.2p2 Ubuntu 4ubuntu2.1 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey:
|   2048 af:b9:68:38:77:7c:40:f6:bf:98:09:ff:d9:5f:73:ec (RSA)
|   256 b9:df:60:1e:6d:6f:d7:f6:24:fd:ae:f8:e3:cf:16:ac (ECDSA)
|_  256 78:5a:95:bb:d5:bf:ad:cf:b2:f5:0f:c0:0c:af:f7:76 (ED25519)
80/tcp open  http    Apache httpd 2.4.18 ((Ubuntu))
| http-robots.txt: 8 disallowed entries
| / /backup /admin /admin_area /r00t /uploads
|_/uploaded_files /flag
|_http-server-header: Apache/2.4.18 (Ubuntu)
| http-title: Sign-Up/Login Form
|_Requested resource was login.php
MAC Address: 08:00:27:68:18:58 (Oracle VirtualBox virtual NIC)
Device type: general purpose
Running: Linux 3.X|4.X
OS CPE: cpe:/o:linux:linux_kernel:3 cpe:/o:linux:linux_kernel:4
OS details: Linux 3.2 - 4.9
Network Distance: 1 hop
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

TRACEROUTE
HOP RTT     ADDRESS
1   0.46 ms 192.168.31.210

OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 8.84 seconds
```

基本的檢測以後發現有開啟 ssh 和 web server 服務，而且有 `robots.txt` ，馬上先看到 `/flag` 得到第一個 flag：
![](Screen%20Shot%202018-05-13%20at%201.57.45%20PM.png)

另外 `robots.txt` 裡面其他的路徑也都看一看，在 `/admin_area` 的 source code 裡看到註解寫著 flag2：
![](Screen%20Shot%202018-05-13%20at%201.59.46%20PM.png)

帳號密碼也找到了以後，首頁的登入表單也成功登入了。
![](Screen%20Shot%202018-05-13%20at%202.01.25%20PM.png)
![](Screen%20Shot%202018-05-13%20at%202.01.34%20PM.png)

同時我也嘗試用這組帳密去登入 ssh，但失敗了。回頭來看剛剛的上傳檔案頁面，既然是上傳那就來試著上傳一個 web shell 看看能不能操作：
![](Screen%20Shot%202018-05-13%20at%202.10.19%20PM.png)

上傳成功，再來想辦法找到上傳的路徑來訪問上傳的檔案，剛剛在 `robots.txt` 中有看到 `/uploads` 和 `/uploaded_files` 的路徑，`/uploads` 是 404，`/uploaded_files/b374k.php` 成功訪問到剛剛上傳的 webshell：
![](Screen%20Shot%202018-05-13%20at%202.14.09%20PM.png)

接下來就在其他路近找找有沒有其他有意思的檔案，在 `/var/www/html` 底下看到 `hint.txt` 和沒有權限讀寫的 `flag.txt` ，`hint.txt` 找到 flag3：
![](Screen%20Shot%202018-05-13%20at%202.16.36%20PM.png)

提示要我們去找 `technawi` 這個使用者的密碼：

```
$ grep -rns technawi /
```

最後我在 `/etc` 找到了 `technawi` 的帳密以及 flag4：
![](Screen%20Shot%202018-05-13%20at%202.24.41%20PM.png)

接著就可以使用 ssh 登入 `technawi`，然後來去看看剛剛因為權限沒辦法看的 `/var/www/html/flag.txt`，flag5 到手：
![](Screen%20Shot%202018-05-13%20at%202.28.31%20PM.png)
