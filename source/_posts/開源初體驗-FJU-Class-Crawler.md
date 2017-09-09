---
title: 開源初體驗 - FJU Class Crawler
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
categories: Blog
thumbnailImage: cover.jpg
tags:
  - GitHub
  - OpenSource
  - FJU
  - Crawler
date: 2017-02-20 21:40:58
coverImage:
keywords:
gallery:
---

心血來潮挖坑給自己跳（？
<!-- more -->

## 前言
怎麼說是心血來潮呢？其實很久以前就想爬學校的課程資料了，不過還沒寫過爬蟲一直不想開坑，直到學長一個晚上就生出了一個Python的課程爬蟲鼓勵（X 刺激（O 了我，當然二話不說就跳進了這個迴圈。

## 開發過程
雖然爬蟲的原理和運作方式大致暸解，但始終沒有實作過，手邊最熟悉的就是寫了一個寒假的[Node.js](https://nodejs.org/)，管他三七二十一編輯器打開就給它開始寫了。

比較痛苦的是，開課資料查詢系統的原始碼非常醜，有的有id有的沒有，三、四層table之類的，花了不少時間解析HTML。程式實作的部分倒是還好，沒有特別複雜或高深的程式設計技巧，或許之後有時間在好好設計一下，總之現在能work就可喜可賀了。

不過就在我的爬蟲能夠撈到資料以後，我才發現我用來測試的工具[Postman](https://www.getpostman.com/)竟然可以直接產生程式碼呀！而且還支援不少程式語言呢！真不知道我花了那麼多時間在看[request](https://www.npmjs.com/package/request)的文件是在看什麼的。結果一問才知道學長也是用Postman直接產生Python的code，只要再實作解析HTML的部分就完成了。

## 結語
作為我寫的第一個爬蟲，個人的想法就是解析HTML的時候很無聊，另一方面感謝學校的系統沒有奇怪的驗證機制或是token，整體來說這次的爬蟲寫得很順利。

最後附上GitHub的連結：[FJU-Class-Crawler](https://github.com/TheoKlein/FJU-Class-Crawler)
有空的話應該還會繼續改善，有興趣的人歡迎Fork發PR。