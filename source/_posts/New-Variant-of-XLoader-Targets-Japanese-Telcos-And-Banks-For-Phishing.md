---
title: New Variant of XLoader Targets Japanese Telcos And Banks For Phishing
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2020-03-31 15:16:02
categories: Research
thumbnailImage: thumb.jpg
coverImage: cover.jpg
keywords:
	- XLoader
	- Android
	- Spyware
	- Phishing
tags:
	- XLoader
	- Android
	- Spyware
	- Phishing
---
We got a new variant of `XLoader` in mid-March 2020. It is a new version of `XLoader` using Blogspot and Pinterest to deliver C&C address and phishing sites.
<!-- more -->

> Cover Photo by Rami Al-zayat on Unsplash

> This article is published on [Talent-Jump Technologies, Inc](http://www.talent-jump.com/article/2020/03/31/New-Variant-of-XLoader-Targets-Japanese-Telcos-And-Banks-For-Phishing/). simultaneously.

Back in 2018, Trend Micro published the [first report](https://blog.trendmicro.com/trendlabs-security-intelligence/xloader-android-spyware-and-banking-trojan-distributed-via-dns-spoofing/) about a new Android Spyware named `XLoader`. Since then, there are many variants of the `XLoader` sample that have been detected and labeled.

The sample we got (`d9adfdd2908fe30eeecb5443787d33d2dc9c4fe5c201665058261c6330af8c98`) seems like a new variant of `XLoader`. These are the things we found different from the old version.

## Payload Encoding

In this sample, it skips the first 4 bytes in `/assets/1a6ddg0/1ua96mi` and uses the fifth byte as a key to XOR the remaining bytes. Then decompress and Base64 decode its content to evade detection.

{% image fancybox center xloader-01.png "Figure 1. The code snippet of decoding and decompressing payload file." %}

{% image fancybox center xloader-02.png "Figure 2. The code snippet of writing Base64 decoded content to file." %}

## Targeted Phishing In Japan
Unlike other old versions of `XLoader`, this sample has some phishing sites majorly targeted on Japanese users.

Like other `Xloader` samples, it hides further payload on normal websites. This time is [Pinterest](https://www.pinterest.com). There are 3 Pinterest users containing phishing site’s URL, each one of them targeted on different carriers' users in Japan.


|URL	|Description	|Carrier	|Alert Message	|Alert Message (EN)	|
|---	|---	|---	|---	|---	|
|https://www.pinterest.com/posylloyd4136/	|`http://au-hha[.]com`	|kddi	|お客様がご利用のキャリア決済が異常ログインの可能性がございます。本人認証設定で危険表示解除お願いします。	|There is a possibility that the carrier billing used by the customer is abnormal login. Please cancel the danger display in the personal authentication settings.	|
|https://www.pinterest.com/amicenorton4874/	|`http://nttdocomo-hha[.]com`	|docomo or ntt	|お客様がキャリア決済にご登録のクレジットカードが外部によるアクセスを検知しました、セキュリティ強化更新手続きをお願いいたします。	|The credit card registered by the customer for carrier billing has detected an external access. Please update your security procedure.	|
|https://www.pinterest.com/ashlynfrancis7577/	|http://	|softbank	|お客様がキャリア決済にご登録のクレジットカードが外部によるアクセスを検知しました、セキュリティ強化更新手続きをお願いいたします。	|The credit card registered by the customer for carrier billing has detected an external access. Please update your security procedure.	|

{% image fancybox center xloader-03.png "Figure 3. The screenshot of one Pinterest user." %}

Furthermore, there are 8 Pinterest users are used to deliver different phishing site’s URL depends on what APPs installed on the user’s device.


|URL	|Description	|APP Package ID	|
|---	|---	|---	|
|https://www.pinterest.com/emeraldquinn4090/	|`http://smbc.bk-securityo[.]com/`	|jp.co.smbc.direct	|
|https://www.pinterest.com/kelliemarshall9518/	|	|jp.co.rakuten_bank.rakutenbank	|
|https://www.pinterest.com/shonabutler10541/	|	|jp.mufg.bk.applisp.app	|
|https://www.pinterest.com/norahspencer9/	|	|jp.co.japannetbank.smtapp.balance	|
|https://www.pinterest.com/singletonabigail/	|	|jp.co.netbk.smartkey.SSNBSmartkey	|
|https://www.pinterest.com/felicitynewman8858/	|	|jp.japanpost.jp_bank.FIDOapp	|
|https://www.pinterest.com/abigailn674/	|	|jp.co.jibunbank.jibunmain	|
|https://www.pinterest.com/gh6855786/	|	|jp.co.sevenbank.AppPassbook	|

At the time of our research, these links had been reported as phishing sites and not available to access. We end up searching online to see if there was some historical data or not.

We found these Pastebin uploaded on Feb 29th, 2020 at 23:34 (UTC-4), they are whois info about `au-hha[.]com` and `nttdocomo-hha[.]com`.

* https://pastebin.com/5yBLXbQ4
* https://pastebin.com/sKuGuG2B

Both domains are registered at the same time at `2020-03-01T03:07:55Z` with the same registrant email `netsusohutsure198720@yahoo.co[.]jp` and phone number `+86.15263254125` from China.

For `smbc.bk-securityo[.]com`, there is a report on [urlscan.io](https://urlscan.io/result/5d2d5703-0d05-4343-b601-e7cbe66befa5/) with a screenshot submitted on Jan 5th, 2020.

{% image fancybox center xloader-04.png "Figure 4. Screenshot from urlscan.io" %}

## Abuse of New Social Media Accounts

In the previous versions, `XLoader` has used many social media to hide its C&C address. In this sample, it used Blogspot to deliver the encoded C&C address in the username.
{% image fancybox center xloader-05.png "Figure 5. The code snippet of default Blogspot accounts." %}

These 3 Blogspot users can be used by different locale’s user. But currently, they all have the same encoded C&C address: `7OlknUJ8RECnMJ0O65Ah8tZJNVjStSHG`.
{% image fancybox center xloader-06.png "Figure 6. Screenshot of Blogspot user “tuyolh”" %}
{% image fancybox center xloader-07.png "Figure 7. Screenshot of Blogspot user “tyhdaou”" %}
{% image fancybox center xloader-08.png "Figure 8. Screenshot of Blogspot user “ajlkhadsflg”" %}


|URL	|Used By Locale	|
|---	|---	|
|https://tuyolh.blogspot.com/?m=1	|Japanese	|
|https://ajlkhadsflg.blogspot.com/?m=1	|Korean	|
|https://tyhdaou.blogspot.com/?m=1	|Other	|

Once it got the encoded C&C address from Blogspot, it will first be doing the Base64 decode then decrypt by DES algorithm (DES/CBC/PKCS5Padding) with hardcoded key `Ab5d1Q32`. In the end, creating a WebSocket connection to the C&C address.

Although this sample gets a C&C address from Blogspot by default, there are other sites can be used to deliver the C&C address we discovered in reversed code.
{% image fancybox center xloader-09.png "Figure 9. The code snippet about different source." %}


Here is the list of these sources:


|Source	|URL	|Regular Expression	|
|---	|---	|---	|
|vk	|`https://m.vk.com/%s?act=info`	|`</dt><dd>([\\w_-]+?)</dd></dl></div></div></div>`	|
|youtube	|`https://m.youtube.com/channel/%s/about`	|`\\{\"description\":\\{\"runs\":\\[\\{\"text\":\"([\\w_-]+?)\"\\}`	|
|ins	|`https://www.instagram.com/%s/`	|`biography\":\"([\\w_-]+?)\"`	|
|GoogleDoc	|`https://docs.google.com/document/d/%s/mobilebasic`	|`<title>([\\w_-]+?)<`	|
|GoogleDoc2	|`https://docs.google.com/document/d/%s/mobilebasic`	|`<title>([\\w_-]+?)/`	|
|blogger	|`https://www.blogger.com/profile/%s`	|`title=\"([\\w_-]+?)&`	|
|blogspot	|`https://%s.blogspot.com/?m=1`	|`author nofollow'>\\n(.+?)\\n`	|
{% raw %}</div><br>{% endraw %}

## Conclusion
Since `XLoader` was named in 2018, it has continuously evolved its hidden methods and continued phishing attacks against different users. Users must be cautious, pay attention to the legality of URL links before entering sensitive information, or confirm whether relevant announcements have been posted on the company's website. Avoid downloading and installing APPs from unknown sources.

---
## IoCs

Sample


|SHA256	|Package	|Label	|
|---	|---	|---	|
|`d9adfdd2908fe30eeecb5443787d33d2dc9c4fe5c201665058261c6330af8c98`	|com.njyi.tvwb	|Chrome	|

Malicious Accounts


|URL	|
|---	|
|https://www.pinterest.com/posylloyd4136/	|
|https://www.pinterest.com/amicenorton4874/	|
|https://www.pinterest.com/ashlynfrancis7577/	|
|https://www.pinterest.com/emeraldquinn4090/	|
|https://www.pinterest.com/kelliemarshall9518/	|
|https://www.pinterest.com/shonabutler10541/	|
|https://www.pinterest.com/norahspencer9/	|
|https://www.pinterest.com/singletonabigail/	|
|https://www.pinterest.com/felicitynewman8858/	|
|https://www.pinterest.com/abigailn674/	|
|https://www.pinterest.com/gh6855786/	|
|https://tuyolh.blogspot.com/?m=1	|
|https://ajlkhadsflg.blogspot.com/?m=1	|
|https://tyhdaou.blogspot.com/?m=1	|

C&C address


| Protocal | IP |
|---	|---   |
| ws:// or wss:// | `128.1.223[.]222:38876` |
{% raw %}</div>{% endraw %}