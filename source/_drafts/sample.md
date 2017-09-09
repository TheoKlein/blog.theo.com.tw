---
title: sample
date: 2016-08-25 20:01:10
categories:
thumbnailImage:
coverImage: 
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
keywords:
	- sample
	- hexo
gallery:
	- image01.jpg "Image 01"
	- image02.jpg
	- http://url/image03.jpg
tags:

---
## 格式參數說明
- categories: 分類
- thumbnailImage: 首頁文章圖片
- coverImage: 文章標頭圖片
- metaAlignment: 文章資訊排版（left, right, center），預設是center
- coverMeta: 文章資訊位置（in, out），預設是in
- gallery: 放在文章最後的圖片集
- keywords: 針對本篇文章搜尋引擎的關鍵字
- thumbnailImagePosition: index 圖片的位置（left, right, bottom），預設是left

## 文內使用圖片
{% raw %}
`{% assest-img image01.jpg %}`
{% endraw %}