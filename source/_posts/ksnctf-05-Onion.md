---
title: 'ksnctf #05 Onion'
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2017-03-22 16:03:44
categories:
	- Writeups
	- ksnctf
thumbnailImage: ksnctf.png
keywords:
    - ksnctf
    - Onion
tags:
    - Writeups
---
題目給了一段非常非常非常非常長的密文
<!-- more -->
第一眼看起像是base64加密的結果，不過丟到online base64 decode解出來還是一長串的密文。其實仔細想一想，加密的內容應該就是Flag或是可能外加一兩句話，長度應該不至於base64加密完以後變得這麼長一串，所以我就寫了一個迴圈連續base64解密，還真的在第16次decode時出現了一段文字：

{% codeblock lang:php %}
<?php
$str = "<ENCODED_STRING>";
for($i = 0 ; $i < 20 ; $i++){
    $str = base64_decode($str);
    echo $str."\n";
}
{% endcodeblock %}

{% blockquote %}
begin 666 <data>
51DQ!1U]&94QG4#-3:4%797I74$AU
`
end
{% endblockquote %}

看到這個嘴角忍不住上揚，這格式不就是之前寫[Root Me](https://www.root-me.org/)某一題用到的[uuencode](https://zh.wikipedia.org/wiki/Uuencode)嗎～  {% raw %}d(`･∀･)b{% endraw %}

二話不說直接解密啦！

{% codeblock lang:php %}
<?php
echo convert_uudecode("51DQ!1U]&94QG4#-3:4%797I74\$AU");
{% endcodeblock %}

{% blockquote %}
FLAG_FeLgP3SiAWezWPHu
{% endblockquote %}

70pt Gotcha!