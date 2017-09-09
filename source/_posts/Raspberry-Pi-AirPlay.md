---
title: Raspberry Pi + AirPlay
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2016-12-22 17:23:52
categories: Blog
thumbnailImage: cover.jpg
keywords:
    - Raspberry Pi2
    - Airplay
tags:
    - Raspberry Pi2
    - Airplay
---
忽然想到把久久沒玩的樹莓派拿出來重裝了最新版本的Raspbian Jessie Lite，準備拿來當作我個人家裡的迷你伺服器。
<!-- more -->

安裝期間爬文爬到了這一篇[文章](http://blog.itist.tw/2016/05/building-airplay-service-on-raspbian-jessie-with-raspberry-pi-3.html)，能讓樹莓派擁有AirPlay的能力，在同一個網路之下都可以串流AirPlay的音訊，當然二話不說馬上來安裝，這裡我自己也簡單記錄一下。

GitHub - [Shairport Sync](https://github.com/mikebrady/shairport-sync)

{% codeblock %}
// clone git project
git clone https://github.com/mikebrady/shairport-sync.git

// install package
sudo apt-get -y install build-essential git autoconf automake libtool libdaemon-dev libasound2-dev libpopt-dev libconfig-dev avahi-daemon libavahi-client-dev libssl-dev libpolarssl-dev libsoxr-dev

// start complie
cd shairport-sync
autoreconf -i -f
./configure --with-alsa --with-stdout --with-pipe --with-avahi --with-ssl=openssl --with-metadata --with-systemd
make

// reate user & group
getent group shairport-sync &> /dev/null || sudo groupadd -r shairport-sync > /dev/null
getent passwd shairport-sync &> /dev/null || sudo useradd -r -M -g shairport-sync -s /usr/bin/nologin -G audio shairport-sync > /dev/null

// install to system
sudo make install
{% endcodeblock %}

修改設定檔，我修改了name和password。
{% codeblock %}
nano /usr/local/etc/shairport-sync.conf
{% endcodeblock %}

{% codeblock %}
// start Shairport Sync
sudo systemctl restart shairport-sync && sudo systemctl status shairport-sync

// set autostart after boot
sudo systemctl enable shairport-sync
{% endcodeblock %}

最後就可以看看iPhone和Mac有沒有出現AirPlay的圖示可以選擇。