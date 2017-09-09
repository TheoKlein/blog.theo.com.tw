---
title: 'picoCTF2017 #LEVEL1'
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2017-06-05 14:21:37
categories:
    - Writeups 
    - picoCTF2017
thumbnailImage: picoctf.jpg
keywords:
    - picoCTF
    - picoCTF 2017
tags:
    - Writeups
    - picoCTF
---
比賽結束這麼久才有空整理出這篇文章~~（其實只是自己太弱到現在才LEVEL 1全解）~~
<!-- more -->
前面Level1基礎的題目的確都還不錯，適合新手來學習（像我），後面的題目慢慢變難有挑戰性...
<!-- toc -->
## Forensics
### [50PTS] Digital Camouflage
題目給了一個`data.pcap`要我們找出密碼，直接查看其檔案內容，其中有一行的內容如下：
> userid=stevensj&pswrd=UjZBS05oV3dvNw%3D%3D

提示裡有說，如果你覺得你找到了密碼可是提交失敗，或許是有加密過的關係。
看了一下`pswrd`，後面有熟悉的`%3D`，這是[URL Encoding](https://en.wikipedia.org/wiki/Percent-encoding)，`%3D -> =`，所以密碼應該是`UjZBS05oV3dvNw==`，但是這樣提交還是會失敗。

再想想其他加密法，長度看起來不像MD5，另一個常用的base64或許可以試試，直接丟到線上[Decoder](https://www.base64decode.org/)轉換，得到`R6AKNhWwo7`，就是此題的flag。

### [50PTS] Special Agent User
同樣給了一個`data.pcap`要我們看看user-agent，我用wireshark打開以後只過濾`http.user_agent`，總共看到9個http request，其中有8個的user-agent是`wget`，只有一個是我們要找的，根據題目的說明，flag的格式是`BrowserName BrowserVersion`，而且`BrowserVersion`的條件是最多要取到3個子版本號，另外如果最後一個子版本號是0的話就忽略。符合條件的只有`Chrome/40.0.2214.93`，根據格式修改後即可得到flag。
> Chrome 40.0.2214

![wireshark](SpecialAgentUser-01.png)

## Cryptography
### [20PTS] keyz
這題僅是基礎知識，要求參賽者將自己電腦的public key藉由web terminal加入到`~/.ssh/authorized_keys`中，即可使用自己的電腦進行SSH登入，登入後就會看到flag。
> Congratulations on setting up SSH key authentication!
> Here is your flag: who_needs_pwords_anyways

### [40PTS] Substitute
基本上題目已經道盡一切了，這題就是一個字母位移加密法的題目，比較常聽到的像是[凱薩加密法](https://en.wikipedia.org/wiki/Caesar_cipher)。不過這題沒有這麼簡單，它並不是有順序的位移，我使用這個[網站](https://www.guballa.de/substitution-solver)來解出密文，language選擇English，它會偵測解密後的文字是否有意義，如果有意義，那麼很可能就是正確的結果。解出來的結果第一句話就看到flag了：
> THE FLAG IS IFONLYMODERNCRYPTOWASLIKETHIS.

### [50PTS] computeAES
認識AES加密演算法，題目只給了以下資訊：
> Encrypted with AES in ECB mode. All values base64 encoded
> ciphertext = I300ryGVTXJVT803Sdt/KcOGlyPStZkeIHKapRjzwWf9+p7fIWkBnCWu/IWls+5S
> key = iyq1bFDkirtGqiFz7OVi4A==

提示說可以是線上工具或是使用Python，當然是要用Python來自幹才好玩。爬了文以後我寫了這個decoder（要先`pip install pycrypto`）：
```python
from Crypto.Cipher import AES
key = 'iyq1bFDkirtGqiFz7OVi4A=='
text = 'I300ryGVTXJVT803Sdt/KcOGlyPStZkeIHKapRjzwWf9+p7fIWkBnCWu/IWls+5S'

aes = AES.new(key.decode('base64'), AES.MODE_ECB)
print aes.decrypt(text.decode('base64'))
```
> flag{do_not_let_machines_win_2d4975bc}{% raw %}__________{% endraw %}

### [50PTS] computeRSA
根據提示的公式使用Python shell直接計算（補上[RSA加密演算法](https://zh.wikipedia.org/wiki/RSA%E5%8A%A0%E5%AF%86%E6%BC%94%E7%AE%97%E6%B3%95)的介紹）
```python
>>> pow(150815, 1941, 435979)
133337
```

## Reverse Engineering
### [20PTS] Hex2Raw
此題需要SSH進入解題環境，目錄下有`hex2raw`的執行檔和`flag`，執行以後出現題目要求：
```
Give me this in raw form (0x41 -> 'A'):
7ca67167db329a5d1508cc4ad5380678

You gave me:

```
之前解別的CTF題目學到的[xxd](http://linuxcommand.org/man_pages/xxd1.html)指令終於要派上用場了！詳細的xxd用法就請自行查看該網頁。

直接使用xxd指令就可以把`hex`轉換成`binary`：
```
$ echo 7ca67167db329a5d1508cc4ad5380678 | xxd -r -p | ./hex2raw
```

```
Yay! That's what I wanted! Here be the flag:
75d3080d00407fa709c18a6cc69d1edc
```

### [20PTS] Raw2Hex
跟上一題非常類似，不過這次要轉回`hex`。同樣可以利用xxd指令來解這題。
```
$ ./raw2hex | xxd -p
54686520666c61672069733ae519e7aa7e593fde891bd24aaa423ea4
```

## Web Exploitation
### [20PTS] What Is Web
就題意看來，似乎希望我們暸解一個網頁的組成，給了這個[網址](http://shell2017.picoctf.com:4079/)。既然要暸解網頁，第一步當然就先看看原始碼。

在首頁的原始碼最後馬上就發現了線索：
```html
<!-- Cool! Look at me! This is an HTML file. It describes what each page contains in a format your browser can understand. -->
<!-- The first part of the flag (there are 3 parts) is 9daca0510ff -->
<!-- What other types of files are there in a webpage? -->
```

把flag拆成三段放在不同地方讓我們繼續去找，原始碼裡還可以看到使用了`hacker.css`和`script.js`兩個檔案，分別開啟便可以在最上方的註解找到第二、第三段flag。
```html
/*
This is the css file. It contains information on how to graphically display
the page. It is in a seperate file so that multiple pages can all use the same 
one. This allows them all to be updated by changing just this one.
The second part of the flag is eb6c5680635 
*/
```

```html
/* This is a javascript file. It contains code that runs locally in your
 * browser, although it has spread to a large number of other uses.
 *
 * The final part of the flag is f1ef52d049f
 */
```
> flag:
> 9daca0510ffeb6c5680635f1ef52d049f

## Binary Exploitation

## Misc

## Master Challenge
### [50PTS] Lazy Dev
題目要求我們登入這個[網站](http://shell2017.picoctf.com:35895/)，看了一下原始碼：
```html
<!DOCTYPE html>
<html lang="en">
<body>
    <h1>Enter the password</h1>
    <input id="password">
    <button type="button" onclick="process_password()">Submit</button>
    <p id="res"></p>

</body>
<script type="text/javascript" src="/static/client.js"></script>
</html>
```

檢查密碼的函式寫在`/static/client.js`裡：
```js
//Validate the password. TBD!
function validate(pword){
  //TODO: Implement me
  return false;
}

//Make an ajax request to the server
function make_ajax_req(input){
  var text_response;
  var http_req = new XMLHttpRequest();
  var params = "pword_valid=" + input.toString();
  http_req.open("POST", "login", true);
  http_req.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
  http_req.onreadystatechange = function() {//Call a function when the state changes.
  	if(http_req.readyState == 4 && http_req.status == 200) {
      document.getElementById("res").innerHTML = http_req.responseText;
    }
  }
  http_req.send(params);
}

//Called when the user submits the password
function process_password(){
  var pword = document.getElementById("password").value;
  var res = validate(pword);
  var server_res = make_ajax_req(res);
}
```
結果檢查密碼的`validate()`根本還沒實作，只會回傳`false`，不過有意思的是，檢查完密碼後，會在利用`make_ajax_req()`發出一次HTTP request，這時就可以用[BurpSuit](https://portswigger.net/burp/)來修改HTTP request。
![false](LazyDev-01.png)
![true](LazyDev-02.png)

成功修改HTTP request並得到flag。
![flag](LazyDev-03.png)
> client_side_is_the_dark_sidebde1f567656f8c9b654a1ec24e1ff889

文章未完待續