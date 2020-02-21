---
title: CLAMBLING - A New Backdoor Base On Dropbox
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2020-02-17 13:22:21
categories: Research
thumbnailImage: thumb.jpg
coverImage: cover.jpg
keywords:
    - CLAMLING
    - DRBControl
    - APT
    - Dropbox
    - DLL Side-Loading
tags:
    - Malware
    - APT
    - IncidentResponse
---
2019 年 7 月，我們發現一個合作的客戶疑似遭受 APT 攻擊並立刻著手調查。調查過程中發現了一種全新的後門樣本，該樣本的特殊之處在於攻擊者利用 Dropbox API 實現了一個具備多種功能的後門惡意程式，並且完美地將 C&C 伺服器建構在 Dropbox 上。透過惡意程式分析，我們獲得了樣本所使用的 Dropbox API Token 並且能夠進一步的深入探討整個架構的運作原理。<!--more-->

> 本文同步發表在 [詮睿科技 Talent-Jump Technologies, Inc.](http://www.talent-jump.com/article/2020/02/17/CLAMBLING-A-New-Backdoor-Base-On-Dropbox/)

> 此報告與 [趨勢科技](https://www.trendmicro.com) 共同研究。
>
> Kenney Lu, Daniel Lunghi, Cedric Pernet, and Jamz Yaneza. (17 February 2020). Trend Micro. ["Operation DRBControl - Uncovering A Cyberespionage Campaign Targeting Gambling Companies In Southeast Asia"](https://www.trendmicro.com/vinfo/us/security/news/cyber-attacks/operation-drbcontrol-uncovering-a-cyberespionage-campaign-targeting-gambling-companies-in-southeast-asia)


[English Version](/Research/CLAMBLING-A-New-Backdoor-Base-On-Dropbox-en)

<!--toc-->

## 第一階段感染

攻擊者利用具備合法數位簽章的 Windows Defender Core Process `MsMpEng.exe`，搭配 DLL Side-Loading 執行 shellcode，讀取 payload 檔案的內容後最終才會釋放真正的惡意程式完成整個第一階段的感染。

作為載體的 `MsMpEng.exe` 在整個調查過程中總共發現有八種 {% raw %}<sub>{% endraw %}[[附錄 1]](#附錄){% raw %}</sub>{% endraw %} 不同的檔名且分別位在 `C:\ProgramData\Microsoft` 各自的資料夾內，其主要目的是透過 DLL Side-Loading 呼叫來自 `mpsvc.dll` 內的 `ServiceCrtMain` 函式。

在這裡發現 `mpsvc.dll` 有新舊版本的差異，其 payload 檔案分別為舊版對應到  `English.rtf` 以及新版對應到 `mpsvc.mui` {% raw %}<sub>{% endraw %}[[附錄 2]](#附錄){% raw %}</sub>{% endraw %}。舊版 `mpsvc.dll` 讀取 `English.rtf` 內容進行解碼後經由 `RtlDecompressBuffer` 解壓縮釋放。新版 `mpsvc.dll` 將 shellcode 寫死在其中，經過解碼後執行其 shellcode 內容，進一步從 `mpsvc.mui` 中讀取後續的 payload。

{% image fancybox center clambling-01.png "圖 1. 舊版 mpsvc.dll" %}

舊版 `mpsvc.dll` 透過 `English.rtf` 所釋放的惡意程式是典型且功能完整的 Backdoor，只會連線到固定的 C&C 伺服器 IP。接下來會著重在新版 `mpsvc.dll` 搭配 `mpsvc.mui` 所釋放的惡意程式，這可以說是舊版本的升級版，除了將部份原有的功能更新之外，更加上了和 Dropbox API 互動的模組。

{% image fancybox center clambling-02.png "圖 2. 新版 mpsvc.dll" %}

新版 `mpsvc.dll` 透過寫死的 shellcode 去分配 0x80000 bytes 的記憶體空間、取得目前 `mpsvc.dll` 的完整路徑並將 `dll` 複寫為 `mui`，最後讀取 `mpsvc.mui` 的內容，再跳至其 base address + 第一個 byte 的位址。

最終 `mpsvc.mui` 將其中寫死的 bytes 透過 `RtlDecompressBuffer` 解壓縮後才會釋放出真正的惡意程式，我們便可以進一步分析該惡意程式究竟具備哪些功能。

{% image fancybox center clambling-03.png "圖 3. mpsvc.dll 裡解碼後的 shellcode" %}

{% image fancybox center clambling-04.png "圖 4. 最終在記憶體裡的惡意程式執行檔" %}

## 樣本分析

抽取出來的惡意程式樣本功能完整，以下是各功能的詳細分析。

### UAC 繞過

{% image fancybox center clambling-05.png "圖 5. 繞過 UAC 的部分程式碼" %}
此樣本具備了 UAC 繞過的能力，在本次大多數受害者電腦上幾乎都能有效發揮。這並不是一種新的手法，早在 2017 年就已經有相關研究 {% raw %}<sub>{% endraw %}[[1]](#參考資料){% raw %}</sub>{% endraw %}披露了這種技巧，攻擊者只將 GUID 更改為 `9BA94120-7E02-46ee-ADC6-10640B04F93B`。

### 權限維持

有兩種方式，如果執行的當下不具備 Administrator 權限，會在 `HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Run` 將自己註冊為開機執行程式。

{% image fancybox center clambling-06.png "圖 6. 註冊成為開機自動執行程式" %}
若具備 Administrator 權限，則會將自己註冊為系統 Service (`HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\services`)。

{% image fancybox center clambling-07.png "圖 7. 註冊成為系統服務" %}
### 資訊收集

{% image fancybox center clambling-08.png "圖 8. 資訊收集的部分程式碼" %}
除了一般電腦資訊例如 IP、hostname、username、作業系統版本等，還會檢查受害者電腦是否有 `HKEY_CURRENT_USER\\Software\\Bitcoin\\Bitcoin-Qt` 的鍵值以及是否有錢包地址資訊，最後以 `%Y-%m-%d %H-%M-%S.log` 的格式上傳到 Dropbox。下方是 log 檔案內容的範例：

```
Lan IP: x.x.x.x
Computer: WIN-XXXXXX
UserName: Administrator
OS: Win10(X64)
Version: 8.0
Bit: Not Found !!!
Exist: NO
```

### 側錄功能

{% image fancybox center clambling-09.png "圖 9. 進行側錄資料編碼的部分程式碼" %}
側錄同時包含了鍵盤輸入以及剪貼簿的內容，兩者分別存入 `<hash>.pas` 和 `<hash>.log`，並對每一個 byte 有做簡單的編碼。

另外也具備螢幕側錄的功能，檔案命名格式為 `[%y-%m-%d] %H-%M-%S.avi`

### 回連 C&C 伺服器

{% image fancybox center clambling-10.png "圖 10. 準備假的 HTTP POST 請求的部分程式碼" %}
該樣本也具備和指定 C&C 伺服器溝通的功能，透過偽造的 HTTP POST 方法並將資料藉由 POST Body 送出。

### RTTI 資訊

此外，該樣本仍保留了 RTTI 資訊，透過 RTTI Class Name 我們可以大致看出該樣本所具備的完整功能。

* CHPAvi
* CHPCmd
* CHPExplorer
* CHPHttp
* CHPKeyLog
* CHPNet
* CHPPipe
* CHPPlugin
* CHPProcess
* CHPProxy
* CHPRegedit
* CHPScreen
* CHPService
* CHPTcp
* CHPTelnet
* CHPUdp

### 與 Dropbox 互動

在逆向分析的過程中，我們發現長度固定為 64 個字元的 access token 單純的以 stack string 的方式寫死在樣本之中。

{% image fancybox center clambling-11.png "圖 11. Dropbox API token 字串陣列的部分程式碼" %}

除了可以和攻擊者的 C&C 伺服器建立連線以外，同時也會透過 Dropbox API 上傳以及下載檔案。此處特別的是上傳完 log 檔以後就會嘗試下載 `bin.asc` 的檔案，並檢查檔案是否具備假的 `GIF` 檔頭，如果確認無誤就會進行客製的解碼，和一個寫死在樣本之中的 byte 陣列計算對應位址真實的 byte，提供後續作為注入攻擊所使用的 payload。


{% image fancybox center clambling-12.png "圖 12. 與 Dropbox 互動的部分程式碼" %}

## Dropbox 內的樣貌

取得樣本所使用的 Dropbox Token 後，透過 Dropbox 官方完整的 API 功能 [2]，我們可以進一步查看 Dropbox 內的檔案現況，例如建立該 Token 的帳號資訊、完整檔案列表等。

Dropbox 內的檔案目錄結構如下：

```
/<unique_hash>/%Y-%m-%d\ %H:%M:%S.log
/<unique_hash>/bin.asc
/codex64bin.asc
/codex86bin.asc
/x64bin.asc
/x86bin.asc
```

每一台感染的電腦會有各自獨立的資料夾，資料夾名稱的格式固定為 `/[0-9A-Z]{8}/` ，這個 hash 是來自每一台感染電腦各自根據機器碼搭配其他資訊所產生的唯一值。 `%Y-%m-%d\ %H:%M:%S.log` 是上傳的 Log 檔，內容為前面所提到資訊收集的部分。`bin.asc` 是攻擊者置入的檔案，在需要進一步動作時上傳至特定的電腦的資料夾內，提供給樣本上傳 log 完畢以後自動嘗試下載執行作進一步的動作。

經過整理也能確認目前所有遭受感染且有回傳資訊的電腦清單：
{% image fancybox center clambling-13.png "圖 13. 整理過後的受感染電腦清單" %}

## 第二階段感染

在前面的第一階段感染完畢以後，樣本本身以系統服務或 autorun 的方式常駐在受感染的電腦，除了收集資訊、側錄、和指定 C&C 伺服器建立連線外，最特別的地方在於每一次成功上傳收集的 log 到 Dropbox 以後，便會嘗試下載 `bin.asc` 。以我們捕捉到所有的 `bin.asc` 進一步分析來看，大多是進一步要求受感染電腦到 Dropbox 下載 `x64bin.asc` 。

進一步分析 `x64bin.asc`，在這個 payload 之中我們發現了第二把 Dropbox Token，該用途跟第一把完全不同，現在攻擊者準備將 Dropbox 做為一個另類的 C&C 伺服器並且也擁有完整的後門控制功能。

第二階段感染的樣本額外具備和 Dropbox 互動的命令對照如下：

|命令代碼|實際動作|
|:---:|:---	|
|  2  |ListDrives	|
|  3  |ListFiles	|
|  4  |ExecuteFile	|
|  5  |ManageFile	|
|  6  |UploadFile	|
|  7  |DownloadFile	|
|  8  |OpenTerminal	|

在這些功能中，會有三個關鍵的檔案各自具備不同的用途串連起整個下達、執行命令且回傳執行結果的流程：

- `eLHgZNBH`：狀態檔
- `yasHPHFJ`：命令檔
- `csaujdnc`：結果檔

狀態檔包含基本的機器資訊和時間等，定時持續的上傳到 Dropbox。每一次成功上傳後，就會嘗試在該電腦獨立的資料夾內下載 `yasHPHFJ` 這個命令檔，如果下載成功並執行完畢，就會將執行結果上傳 Dropbox 存為 `csaujdnc` 檔案：下方這個流程圖簡單的描述了這三個檔案的互動流程。

{% image fancybox center clambling-14.png "圖 14. 三個特殊檔案與 Dropbox 互動的流程圖" %}

透過這樣的方式，攻擊者便可以將 Dropbox 作為 C&C 伺服器的中繼站，即使原先固定連線的 C&C 伺服器 IP 被發現且受到阻擋，仍然可以透過 Dropbox 掌控受害主機，除非阻擋 `content.dropboxapi.com` 和 `api.dropboxapi.com`，否則無法有效的完整隔離，但這將會影響所有內部使用者使用  Dropbox 服務。

因為 Dropbox API 保留了完整且詳盡的檔案、資料夾資訊，例如下方是一個檔案的回傳資訊：

```
{
    '.tag': 'file',
    'name': 'Secret_File.txt',
    'path_lower': '/secret_file.txt',
    'path_display': '/Secret_File.txt',
    'id': 'id:<UNIQUE_FILE_ID>',
    'client_modified': '2019-07-21T02:45:42Z',
    'server_modified': '2019-07-21T02:53:04Z',
    'rev': '[0-9a-f]{6,}',
    'size': 125,
    'is_downloadable': True,
    'content_hash': '<SHA256_HASH>'
}
```

我們可以精確地得到本機修改時間、上傳時間，甚至如果該檔案有被覆蓋的歷史版本，透過 `rev` 參數我們也能列出該檔案所有歷史版本的詳細資訊，並且將這些檔案下載回來。利用這些資訊搭配前面逆向所解析出來的命令對照及參數，匯集每一台電腦的 `yasHPHFJ` 檔案，我們便可以整理出每台感染電腦過去曾經被執行過的所有命令、參數和時間點列表，下面兩張圖片是兩台電腦實際解析後的結果以時間做排序。

{% image fancybox center clambling-15.png "圖 15. 受感染電腦的命令執行結果清單" %}
{% image fancybox center clambling-16.png "圖 16. 另一台受感染電腦的命令執行結果清單" %}

根據解析出來的這些紀錄，攻擊者在每台電腦都遵循著差不多的動作流程。首先透過 Dropbox 下載額外的攻擊程式，例如 mimikatz 或是嘗試提權、UAC 繞過等工具，之後便開始搜索有價值的檔案，例如側錄的 keylog / clipboard log、公司內部文件、設定檔、原始碼、資料庫內容等，全部上傳到 Dropbox。攻擊者找到並竊取了機敏資訊後持續進行橫向擴散，最終近乎完全滲透公司內部、Cloud Server 等各環境。

將所有的 `yasHPHFJ` 命令檔解析並整理過後，我們可以大略的統計出攻擊者的作息時間如下圖：

{% image fancybox center clambling-17.png "圖 17. 攻擊者大略的作息時間" %}

## 總結

在分析並取得 Dropbox Token 之後，我們持續監控各 Dropbox APP 內的檔案變化，可以觀察出在 2019 年 7 月 ~ 2019 年 9 月兩個月之中受感染電腦的數量變化。

{% image fancybox center clambling-18.png "圖 18. Dropbox A 的感染電腦數量變化圖" %}
{% image fancybox center clambling-19.png "圖 19. Dropbox B 的感染電腦數量變化圖" %}

最高峰的時期曾經在 Dropbox A 監測到將近 200 台受害電腦回傳資訊，兩者數量皆在 2019/08/20 這天出現大落差，推測可能是攻擊者在清理 Dropbox 上的資料進行重置，直到 2019/09/20 所有我們已知的 Dropbox Token 皆失效。

整個研究過程中總共發現超過 5 把不同的 Dropbox Token，其中主要的兩把就是本文前面所介紹的內容，其他把 Token 觀察下來比較像是攻擊者用來測試或額外分類存放資料所使用的。

整個和 Dropbox 互動的流程可以描繪成下圖：
{% image fancybox center clambling-20.png "圖 20. 整體感染流程圖" %}

從最一開始的感染點完成第一階段感染以後，同時具備與特定 C&C 伺服器和 Dropbox 的連線，當 C&C 伺服器 IP 受到阻擋或封鎖時，仍然可以透過 Dropbox 持續接收受感染電腦的資訊，並且上傳 `bin.asc` 對受感染電腦下達其他指令。要求受感染電腦下載 `x64bin.asc` 後完成第二階段感染，更進一步善用 Dropbox 實現完整且即時的遠端控制能力，持續的竊取資料以及橫向滲透，方法簡單但卻十分有效。

## 附錄

1. 載體列表
    - `33bc14d231a4afaa18f06513766d5f69d8b88f1e697cd127d24fb4b72ad44c7a`
      - `msmpeng.exe` (PE32)
    - `99042e895b6c2ea80f3ba65563a12c8eba882e3ad6a21dd8e799b0112c75ddd2`
      - `rsoplicy.exe` (PE32+)
      - `DRM.exe` (PE32+)
      - `Firewall.exe` (PE32+)
      - `Kaspe.exe` (PE32+)
      - `RSoPProv.exe` (PE32+)
      - `Video.exe` (PE32+)
      - `WinDRM.exe` (PE32+)


2. DLL 和搭配 Payload 檔案列表
    - `mpsvc.dll`
        - `a58946c10c8325040634f7cd04429b9f1e3715767d0c8aec46b7cba8975e6a69`
        - `e18af309ecc3bc93351b9fa13a451e8b55b71d9edcc4232bc53eb1092bdfa859`
    - `English.rtf`
        - `52c147c8eadb58d3580b39c023ce4a90dacce76ee5c30c56c56ea39939a56b52`
        - `b5546d4931a0316abd4018c982558ed808b4d0a60233ac18bee601fa09d95ee6`
        - `dd0399970d2dbb5ab8b5869e2fafb83194c992f27bbb244adce35e2fe6ef0d28`
    - `mpsvc.mui`
        - `0693713f995285e8bd99ebfca2c4f0f1a8e824dafb5a99693442a9256df06e02`
        - `24ebd398be23135a2d8aa7000c2b6a534448b87aa5708b8546089630a8035f7e`
        - `56758c25e3b00957c6f7f76fcea5d0598eff7eda98c63f50b51d1c28f267ac8f`
        - `96282a625a31b6bf646c6e01ad20de96fd63c345881a9c91190940121580059d`
        - `99663b9ba27a36ff9fc64b72213e933067ee0cde38b39d20ae4326a37185811d`
        - `9dd1d21e9431cfe25709a8f26ec0f605ed19cf64ca1922e97fad7b7f2d2e82ea`
        - `b226c8e85a7b1a6d4d29d42fc84bc7f3a32335fc7ba44b455a7716d706660873`
        - `be4efb1b8e3dd4a103dda7d643ffb12022a051857027aa44d86a3a710922db87`
        - `e716506cf54f48d77382d8955512184b45dd7d0b58c22e32424c56d38db24360`

- 其他 IoCs
    - Drop Files
        - `37286285cb0f8305bd23a693b2e7ace71538e4c0b9f13ee6ca4e9e9419657813`
        - `b3581e8611f5838fc205f66bc5ca5edddb0fd895e97ebf8f0c7220cb102ae14b`
        - `79928578cdd646a9724bc6851a1ee77820c81a3100788d62885f9d92b6814085`
        - `7602e2932a10f3750a5d6236f6c1662047d4475c6e1fe6c57118c6620a083cb3`
        - `5b5aff8869ba7f1d3f6ad7711e801b031aedeff287a0dcb8f8ae6d6e4eb468af`
        - `412260ab5d9b2b2aa4471b953fb67ddc1a0fe90c353e391819ca7ac1c6d3146f`
        - `c6064fb44733b5660557e223598d0e4d5c4448ad20b29e41bef469cb5df77da0`
        - `4c08bc1a2f5384c5306edc6f23e4249526517eb21a88763c8180a582438dfa31`
        - `a58f2fea8c74c1d25090014c7366db224102daa6c798fcdfb7168b569b7d5ca2`
        - `d201e726fd2a2f4b55ea5ca95f0429d74e2efb918c7c136d55ef392ceac854d6`
        - `5713907c01db40cf54155db19c0c44c046b2c676a492d5ba13d39118c95139bf`
        - `d72c3f5f2f291f7092afd5a0fcaceaf2eaae44d057c9b3b27dd53f2048ed6175`
        - `d62ddac7c4aa152cf6f988db6c7bd0c9dcffa2e890d354b7e9db7f3b843fd270`
        - `28d2637139231c78a6493cd91e8f0d10891cfeb6c5e758540515faa29f54b6b2`
        - `39e69ab52f073f966945fdab214f63368f71175a7ccbea199fae32d51fa6a4e7`
        - `260b64e287d13d04f1f38d956c10d9fdd3cfbff6ba0040a52223fa41605bb975`
        - `c425b73be7394032aa8e756259ebf3662c000afaa286c3d7d957891026f3cbb4`
        - `28d19a23d167db3e1282f1c6039bcda6556798be054994a55e60116827dd0bf1`
        - `c3c1fc6aabbb49d0ee281ba4fc1529d2b9832a67b18e08ce14dbf0e361e5bd85`
        - `fc865a720cb808354923092bac04ab6a75e20ea92db5a343af07365c0cd2b72a`
        - `24f501141af5bf059509145e165302dd7087b1d1c2136bc5e4403f01435f250e`
        - `ee5f7e6ad4a344f40b9babada1654ea22333bb5150cfd26bfc239ead28b6528c`
        - `ca26a34153972cc73c63d3a9aadd3b12ba35ecdc6e39025b75be56b00c20e0ae`
        - `1951c79f280692a43b7c7cafd45c3f5d7f4f841ae104a6cad814fab4641c79f2`
        - `d5129308ee83a852e6a320ca68c8e66ed6d1eb4ec584dd0c8b5f313a56c49a15`
    
    - IP
      - `103.230.15.130`
      - `104.168.196.80`
      - `104.168.196.85`
      - `104.168.196.88`
      - `139.180.194.173`
      - `167.179.115.228`
      - `207.148.73.58`
      - `43.228.126.172`
      - `43.228.126.56`
      - `45.32.101.238`
      - `45.32.111.228`
      - `45.77.41.49`
      - `47.75.248.237`
      - `66.42.60.107`
    
    - Domains
      - `fn.shopingchina.net`
      - `office.support.googldevice.com`
      - `safe.mircosofdevice.com`
      - `server.correomasivochile.com`
      - `srv2.mkt-app.com`
      - `store.microsoftbetastore.com`
      - `update.mircosotfdefender.com`

## 參考資料

1. [UAC bypass via elevated .NET applications](https://offsec.provadys.com/UAC-bypass-dotnet.html)
2. [Dropbox for HTTP Developers](https://www.dropbox.com/developers/documentation/http/overview)
3. [Kenney Lu, Daniel Lunghi, Cedric Pernet, and Jamz Yaneza. (17 February 2020). *Trend Micro*. "Operation DRBControl - Uncovering A Cyberespionage Campaign Targeting Gambling Companies In Southeast Asia"](https://www.trendmicro.com/vinfo/us/security/news/cyber-attacks/operation-drbcontrol-uncovering-a-cyberespionage-campaign-targeting-gambling-companies-in-southeast-asia)

> Photo by [Fotis Fotopoulos](https://unsplash.com/@ffstop) on [Unsplash](https://unsplash.com/)