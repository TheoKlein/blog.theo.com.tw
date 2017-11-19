---
title: 'ksnctf #03 Crawling Chaos'
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2017-03-23 00:05:36
categories:
	- Writeups
	- ksnctf
thumbnailImage: ksnctf.png
keywords:
    - ksnctf
    - Crawling Chaos
tags:
    - Writeups
---
原來顏文字可以這麼強大 {% raw %}(´⊙ω⊙`){% endraw %}
<!-- more -->

題目的原始碼script裡面充滿著大量的顏文字，以下節錄一小部份：

{% blockquote %}
(ᒧᆞωᆞ)=(/ᆞωᆞ/),(ᒧᆞωᆞ).ᒧうー=-!!(/ᆞωᆞ/).にゃー,(〳ᆞωᆞ)=(ᒧᆞωᆞ),(〳ᆞωᆞ).〳にゃー=- -!(ᒧᆞωᆞ).ᒧうー,(ᒧᆞωᆞ).ᒧうーｰ=(〳ᆞωᆞ).〳にゃー- -!(ᒧᆞωᆞ).ᒧうー,(〳ᆞωᆞ).〳にゃーｰ=(ᒧᆞωᆞ).ᒧうーｰ- -(〳ᆞωᆞ).〳にゃー,(ᒧᆞωᆞ).ᒧうーー=(〳ᆞωᆞ).〳にゃーｰ- -!(ᒧᆞωᆞ).ᒧうー,(〳ᆞωᆞ).〳にゃーー=(ᒧᆞωᆞ).ᒧうーー- -(〳ᆞωᆞ).〳にゃー,(ᒧᆞωᆞ).ᒧうーｰｰ=(〳ᆞωᆞ).〳にゃーー- -!(ᒧᆞωᆞ).ᒧうー,(〳ᆞωᆞ).〳にゃーｰｰ=(ᒧᆞωᆞ).ᒧうーｰｰ- -(〳ᆞωᆞ).〳にゃー,(ᒧᆞωᆞ).ᒧうーｰー=(〳ᆞωᆞ).〳にゃーｰｰ- -!(ᒧᆞωᆞ).ᒧうー,(〳ᆞωᆞ).〳にゃーｰー=(ᒧᆞωᆞ).ᒧうーｰー- -(〳ᆞωᆞ).〳にゃー,ｰ='',(ᒧᆞωᆞ).ᒧうーーｰ=!(ᒧᆞωᆞ).ᒧうー+ｰ,(〳ᆞωᆞ).〳にゃーーｰ=!(〳ᆞωᆞ).〳にゃー+ｰ,(ᒧᆞωᆞ).ᒧうーーー={這いよれ:!(〳ᆞωᆞ).〳にゃー}+ｰ,(〳ᆞωᆞ).〳にゃーーー=(ᒧᆞωᆞ).ᒧニャル子さん+ｰ,(ᆞωᆞᒪ)=(ｺᆞωᆞ)=(ᒧᆞωᆞ).ᒧうー,(ᒧᆞωᆞ).ᒧうーｰｰｰ=(〳ᆞωᆞ).〳にゃーーｰ[(ᆞωᆞᒪ)- -(〳ᆞωᆞ).〳にゃー-(ｺᆞωᆞ)],(〳ᆞωᆞ).〳にゃーｰｰｰ=(ᒧᆞωᆞ).ᒧうーーー[(ᆞωᆞᒪ)- -(ᒧᆞωᆞ).ᒧうーｰ-(ｺᆞωᆞ)],(ᒧᆞωᆞ).ᒧうーｰｰー=(ᒧᆞωᆞ).ᒧうーーー[(ᆞωᆞᒪ)- -(〳ᆞωᆞ).〳にゃーー-(ｺᆞωᆞ)],(〳ᆞωᆞ).〳にゃーｰｰー=(〳ᆞωᆞ).〳にゃーーー[(ᆞωᆞᒪ)- -(ᒧᆞωᆞ).ᒧうーｰ-(ｺᆞωᆞ)],(ᒧᆞωᆞ).ᒧうーｰーｰ=(ᒧᆞωᆞ).ᒧうーーｰ[(ᆞωᆞᒪ)- -(〳ᆞωᆞ).〳にゃーｰ-(ｺᆞωᆞ)],(〳ᆞωᆞ).〳にゃーｰーｰ=(〳ᆞωᆞ).〳にゃーーｰ[(ᆞωᆞᒪ)-(ｺᆞωᆞ)],(ᒧᆞωᆞ).ᒧうーｰーー=(〳ᆞωᆞ).〳にゃーーー[(ᆞωᆞᒪ)- -(〳ᆞωᆞ).〳にゃー-(ｺᆞωᆞ)],(〳ᆞωᆞ).〳にゃーｰーー=(ᒧᆞωᆞ).ᒧうーーー[(ᆞωᆞᒪ)- -(〳ᆞωᆞ).〳にゃー-(ｺᆞωᆞ)],(ᒧᆞωᆞ).ᒧうーーｰｰ=(ᒧᆞωᆞ).ᒧうーーｰ[(ᆞωᆞᒪ)- -(〳ᆞωᆞ).〳にゃー-(ｺᆞωᆞ)],(〳ᆞωᆞ).〳にゃーーｰｰ=(〳ᆞωᆞ).〳にゃーーｰ[(ᆞωᆞᒪ)- -(〳ᆞωᆞ).〳にゃーｰ-(ｺᆞωᆞ)],(ᒧᆞωᆞ).ᒧうーーｰー=(ᒧᆞωᆞ).ᒧうーーｰ[(ᆞωᆞᒪ)-(ｺᆞωᆞ)],(〳ᆞωᆞ).〳にゃーーｰー=(〳ᆞωᆞ).〳にゃーーー[(ᆞωᆞᒪ)-(ｺᆞωᆞ)],(ᒧᆞωᆞ).ᒧうーーーｰ=/""ω""/+/\\ω\\/,(〳ᆞωᆞ).〳にゃーーーｰ=(ᒧᆞωᆞ).ᒧうーーーｰ[(ᆞωᆞᒪ)- -(〳ᆞωᆞ).〳にゃー-(ｺᆞωᆞ)],(ᒧᆞωᆞ).ᒧうーーーー=(ᒧᆞωᆞ).ᒧうーーーｰ[(ᆞωᆞᒪ)- -(〳ᆞωᆞ).〳にゃーｰー-(ｺᆞωᆞ)],(〳ᆞωᆞ).〳にゃーーーー=(ᒧᆞωᆞ).ᒧうーーーー+(〳ᆞωᆞ).〳にゃーーｰー,(ᒧᆞωᆞ).ᒧうーｰｰｰｰ=(〳ᆞωᆞ).〳にゃーーーー+(ᒧᆞωᆞ).ᒧうー+(ᒧᆞωᆞ).ᒧうー,(〳ᆞωᆞ).〳にゃーｰｰｰｰ
{% endblockquote %}

雖然馬上可以知道肯定是某種JS混淆，但這樣子的混淆方式還真的是第一次看到。是有搜尋到一位日本人發明的[aaencode](http://utf-8.jp/public/aaencode.html)，但找到的online decoder沒辦法解密出來，思考了一段時間意識到最近都在寫Node.js，既然這是個script那為何不丟給Node.js執行看看呢？不丟還好，一丟不得了，還真的把東西全噴出來了！

{% codeblock lang:js%}
undefined:2
$(function(){$("form").submit(function(){var t=$('input[type="text"]').val();var p=Array(70,152,195,284,475,612,791,896,810,850,737,1332,1469,1120,1470,832,1785,2196,1520,1480,1449);var f=false;if(p.length==t.length){f=true;for(var i=0;i<p.length;i++)if(t.charCodeAt(i)*(i+1)!=p[i])f=false;if(f)alert("(」・ω・)」うー!(/・ω・)/にゃー!");}if(!f)alert("No");return false;});});
^

ReferenceError: $ is not defined
{% endcodeblock %}

總而言之呢，souce code到手了，整理一下分析程式碼就可以發現其實只是簡易的數學運算而已。

{% codeblock lang:js %}
$(function () {
    $("form").submit(function () {
        var t = $('input[type="text"]').val();
        var p = Array(70, 152, 195, 284, 475, 612, 791, 896, 810, 850, 737, 1332, 1469, 1120, 1470, 832, 1785, 2196, 1520, 1480, 1449);
        var f = false;
        if (p.length == t.length) {
            f = true;
            for (var i = 0; i < p.length; i++)
                if (t.charCodeAt(i) * (i + 1) != p[i]) f = false;
            if (f) alert("(」・ω・)」うー!(/・ω・)/にゃー!");
        }
        if (!f) alert("No");
        return false;
    });
});
{% endcodeblock %}

寫個簡易的C程式就可以順利拿到flag。

{% codeblock lang:c %}
#include <stdio.h>

int main(){
    int i, arrar[30] = {70, 152, 195, 284, 475, 612, 791, 896, 810, 850, 737, 1332, 1469, 1120, 1470, 832, 1785, 2196, 1520, 1480, 1449};
    for(i = 0 ; i < 21; i++)
        printf("%c", array[i] / (i + 1));
    return 0;
}
{% endcodeblock %}

{% blockquote %}
FLAG_fqpZUCoqPb4izPJE
{% endblockquote %}