---
title: 新 XLoader 變種瞄準日本電信商及銀行進行網路釣魚
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2020-03-31 15:15:58
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
我們在三月中旬經由詐騙簡訊的連結 `http://wrssa[.]xyz` 獲得了一個 XLoader 的新變種樣本，這個新變種利用 Blogspot 和 Pinterest 來隱藏 C&C 位址以及釣魚網站。
<!-- more -->

> Cover Photo by Rami Al-zayat on Unsplash

> 本文同步發表在 詮睿科技 [Talent-Jump Technologies, Inc](http://www.talent-jump.com/article/2020/03/31/新-XLoader-變種瞄準日本電信商及銀行進行網路釣魚/).

{% raw %}<br>{% endraw %}
{% image fancybox center xloader-00.jpeg "Figure 1. 詐騙簡訊截圖" %}

在 2018 年時，趨勢科技發佈了一篇 [報告](https://blog.trendmicro.com/trendlabs-security-intelligence/xloader-android-spyware-and-banking-trojan-distributed-via-dns-spoofing/) 描述一種全新的 Android 間諜程式並將其命名為 `XLoader`。從那之後，`XLoader` 持續不斷的有新變種出現並且持續在進行攻擊。

我們得到的樣本（`d9adfdd2908fe30eeecb5443787d33d2dc9c4fe5c201665058261c6330af8c98`）看起似乎是新的 `XLoader` 變種，這些是我們發現跟過去已知版本的 `XLoader` 有所不同的地方。

## 加密的資源檔案
在這個樣本嘗試解開資源檔案 `/assets/1a6ddg0/1ua96mi` 的部分，它會跳過前 4 個位元並將第 5 個位元當作 key，對剩餘的每一個位元和此 key 進行 XOR 運算，最後才進行解壓縮和 Base64 解碼來釋放攻擊模組，藉此躲避偵測。

{% image fancybox center xloader-01.png "Figure 2. 資源檔案解碼和解壓縮的部分程式碼" %}
{% image fancybox center xloader-02.png "Figure 3. Base64 解碼後寫入檔案的部分程式碼" %}

## 針對日本進行網路釣魚
不像其他舊版本的 `XLoader`，這個樣本主要針對日本的電信商以及銀行使用者進行網路釣魚。

它隱藏釣魚網站的手法和以往相同，將資料藏在一些合法的社交網站上，這一次是 [Pinterest](https://www.pinterest.com)。 有 3 個 Pinterest 帳號的描述中藏有釣魚網站的連結，這三個連結分別瞄準不同的日本電信商使用者。

{% raw %}<div style="overflow-x:auto;">{% endraw %}
|URL |Description |電信商 |通知訊息 |通知訊息（中文） |
|--- |--- |--- |--- |--- |
|https://www.pinterest.com/posylloyd4136/ |`http://au-hha[.]com` |kddi |お客様がご利用のキャリア決済が異常ログインの可能性がございます。本人認証設定で危険表示解除お願いします。 |客戶使用的運營商計費有可能是異常登錄。 請取消個人身份驗證設置中的危險顯示。 |
|https://www.pinterest.com/amicenorton4874/ |`http://nttdocomo-hha[.]com` |docomo or ntt |お客様がキャリア決済にご登録のクレジットカードが外部によるアクセスを検知しました、セキュリティ強化更新手続きをお願いいたします。 |您註冊用於運營商代扣的信用卡已檢測到外部的異常訪問。請更新並強化您的安全設定。 |
|https://www.pinterest.com/ashlynfrancis7577/ |http:// |softbank |お客様がキャリア決済にご登録のクレジットカードが外部によるアクセスを検知しました、セキュリティ強化更新手続きをお願いいたします。 |您註冊用於運營商代扣的信用卡已檢測到外部的異常訪問。請更新並強化您的安全設定。 |
{% raw %}</div>{% endraw %}

{% image fancybox center xloader-03.png "Figure 4. 其中一個 Pinterest 帳號的截圖" %}

另外還有 8 個 Pinterest 帳號被用來存放瞄準日本銀行相關的釣魚網站，會根據使用者裝置上有安裝不同銀行的 APP 來使用不同的釣魚網站連結。

{% raw %}<div style="overflow-x:auto;">{% endraw %}
|URL |Description |APP Package ID |
|--- |--- |--- |
|https://www.pinterest.com/emeraldquinn4090/ |`http://smbc.bk-securityo[.]com/` |jp.co.smbc.direct |
|https://www.pinterest.com/kelliemarshall9518/ | |jp.co.rakuten_bank.rakutenbank |
|https://www.pinterest.com/shonabutler10541/ | |jp.mufg.bk.applisp.app |
|https://www.pinterest.com/norahspencer9/ | |jp.co.japannetbank.smtapp.balance |
|https://www.pinterest.com/singletonabigail/ | |jp.co.netbk.smartkey.SSNBSmartkey |
|https://www.pinterest.com/felicitynewman8858/ | |jp.japanpost.jp_bank.FIDOapp |
|https://www.pinterest.com/abigailn674/ | |jp.co.jibunbank.jibunmain |
|https://www.pinterest.com/gh6855786/ | |jp.co.sevenbank.AppPassbook |
{% raw %}</div>{% endraw %}

在我們研究的時候，這些連結已經被回報為釣魚網站且無法訪問，最後我們只好搜尋有無相關的歷史資料留存在網路上。

我們找到這 2 個 Pastebin 在 2020/02/29 23:34（UTC-4）的時候被上傳，這些是 `au-hha[.]com` 和 `nttdocomo-hha[.]com` 當時的 WHOIS 資訊。

* https://pastebin.com/5yBLXbQ4
* https://pastebin.com/sKuGuG2B

兩個域名的註冊時間都在 `2020-03-01T03:07:55Z` 並且有相同的註冊信箱 `netsusohutsure198720@yahoo[.]co[.]jp` 以及來自中國的手機門號 `+86.15263254125`。

至於 `smbc.bk-securityo[.]com`，我們找到一份來自 [urlscan.io](https://urlscan.io/result/5d2d5703-0d05-4343-b601-e7cbe66befa5/) 的掃描報告，掃描日期是 2020/01/05，當時確實是針對日本三井住友銀行（SMBC）精心設計的釣魚網站。

{% image fancybox center xloader-04.png "Figure 5. 來自 urlscan.io 掃描報告的截圖" %}

## 濫用新的社交網站帳號

在之前的 `XLoader` 版本中，曾經利用例如 Twitter 來隱藏其真實的 C&C 位址。在這個樣本中，它使用 Blogspot 使用者的名稱來隱藏加密過的 C&C 位址。
{% image fancybox center xloader-05.png "Figure 6. 預設帳號的程式碼片段" %}

這三個 Blogspot 帳號可以被不同語系的使用者所用，但目前我們所看到的三個帳號都擁有相同加密過的 C&C 位址：`7OlknUJ8RECnMJ0O65Ah8tZJNVjStSHG`。
{% image fancybox center xloader-06.png "Figure 7. Blogspot 使用者 “tuyolh” 的截圖" %}
{% image fancybox center xloader-07.png "Figure 8. Blogspot 使用者 “tyhdaou” 的截圖" %}
{% image fancybox center xloader-08.png "Figure 9. Blogspot 使用者 “ajlkhadsflg” 的截圖" %}

{% raw %}<div style="overflow-x:auto;">{% endraw %}
|URL |語系 |
|--- |--- |
|https://tuyolh.blogspot.com/?m=1 |Japanese |
|https://ajlkhadsflg.blogspot.com/?m=1 |Korean |
|https://tyhdaou.blogspot.com/?m=1 |Other |
{% raw %}</div>{% endraw %}

一但 `XLoader` 從 Blogspot 獲得了加密過的 C&C 位址，他會先進行 Base64 解碼再利用寫死的 key `Ab5d1Q32` 做 DES 解密（DES/CBC/PKCS5Padding），最後獲得真實的 C&C 位址並建立起 WebSocket 連線。

雖然這個樣本預設是從 Blogspot 取得 C&C 位址，但我們經由逆向工程發現此樣本也具備從其他網站取得資料的功能。
{% image fancybox center xloader-09.png "Figure 10. 不同的資料來源的部分程式碼" %}

以下是全部的來源清單列表：

{% raw %}<div style="overflow-x:auto;">{% endraw %}
|Source	|URL	|Regular Expression	|
|---	|---	|---	|
|vk	|`https://m.vk.com/%s?act=info`	|`</dt><dd>([\\w_-]+?)</dd></dl></div></div></div>`	|
|youtube	|`https://m.youtube.com/channel/%s/about`	|`\\{\"description\":\\{\"runs\":\\[\\{\"text\":\"([\\w_-]+?)\"\\}`	|
|ins	|`https://www.instagram.com/%s/`	|`biography\":\"([\\w_-]+?)\"`	|
|GoogleDoc	|`https://docs.google.com/document/d/%s/mobilebasic`	|`<title>([\\w_-]+?)<`	|
|GoogleDoc2	|`https://docs.google.com/document/d/%s/mobilebasic`	|`<title>([\\w_-]+?)/`	|
|blogger	|`https://www.blogger.com/profile/%s`	|`title=\"([\\w_-]+?)&`	|
|blogspot	|`https://%s.blogspot.com/?m=1`	|`author nofollow'>\\n(.+?)\\n`	|
{% raw %}</div>{% endraw %}

## 結語
`XLoader` 自 2018 年被命名以來，不斷的演變其隱藏的手法並且針對不同族群持續進行網路釣魚攻擊。使用者須多加謹慎，輸入敏感資料前注意網址連結的合法性，或是確認有無相關公告發佈在該公司網站。對於未知來源的 APP 應盡量避免下載及安裝。

---
## IoCs

樣本

{% raw %}<div style="overflow-x:auto;">{% endraw %}
|SHA256 |Package |Label |
|--- |--- |--- |
|`d9adfdd2908fe30eeecb5443787d33d2dc9c4fe5c201665058261c6330af8c98` |com.njyi.tvwb |Chrome |
{% raw %}</div>{% endraw %}

惡意帳號

{% raw %}<div style="overflow-x:auto;">{% endraw %}
|URL |
|--- |
|https://www.pinterest.com/posylloyd4136/ |
|https://www.pinterest.com/amicenorton4874/ |
|https://www.pinterest.com/ashlynfrancis7577/ |
|https://www.pinterest.com/emeraldquinn4090/ |
|https://www.pinterest.com/kelliemarshall9518/ |
|https://www.pinterest.com/shonabutler10541/ |
|https://www.pinterest.com/norahspencer9/ |
|https://www.pinterest.com/singletonabigail/ |
|https://www.pinterest.com/felicitynewman8858/ |
|https://www.pinterest.com/abigailn674/ |
|https://www.pinterest.com/gh6855786/ |
|https://tuyolh.blogspot.com/?m=1 |
|https://ajlkhadsflg.blogspot.com/?m=1 |
|https://tyhdaou.blogspot.com/?m=1 |
{% raw %}</div>{% endraw %}

C&C 位址

{% raw %}<div style="overflow-x:auto;">{% endraw %}
| Protocal | IP |
|--- |---   |
| http:// | `wrssa[.]xyz` |
| ws:// or wss:// | `128.1.223[.]222:38876` |
{% raw %}</div>{% endraw %}