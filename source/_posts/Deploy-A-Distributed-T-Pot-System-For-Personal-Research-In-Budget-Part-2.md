---
title: Deploy A Distributed T-Pot System For Personal Research In Budget - Part 2
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2020-10-13 23:52:13
categories:
    - Research
coverImage: banner.png
thumbnailImage: cover.jpg
keywords:
    - T-Pot
    - honeypot
    - distributed
    - wireguard
tags:
    - honeypot
---
A distributed honeypot system based on [T-Pot 20.06.1](https://github.com/telekom-security/tpotce/releases/tag/20.06.1), hello [Filebeat](https://www.elastic.co/beats/filebeat)!
<!-- more -->

After I successfully deployed my distributed honeypot and published the article "[Deploy A Distributed T-Pot System For Personal Research In Budget](/Research/Deploy-A-Distributed-T-Pot-System-For-Personal-Research-In-Budget/)" a year ago, it works without any critical problems.

On June 30, 2020, [T-Pot 20.06.0](https://github.com/telekom-security/tpotce/releases/tag/20.06.0) was released and I want to take this opportunity to rebuild my distributed honeypot system. After some experiments I noticed that in the new version, Logstash could not startup when the memory limit is set to a maximum of 512MB or even 1GB on the VPS (1 CPU / 1GB RAM with 3GB swap). My goal is not changed and I don't want to upgrade the VPS just for more RAM. So, here comes the new data flow with [Filebeat](https://www.elastic.co/beats/filebeat) and this blog.

## New Data Flow

![dataflow](dataflow.png)
Unlike the original data flow which has Logstash installed on every sensor node to process and send log back to the central collector server. Filebeat takes the role to do only one job: send raw data back to the Logstash on the central collector server. That means, I need to write a `filebeat.yml` config for T-Pot, you can refer to my forked T-Pot repository at [here](https://github.com/TheoKlein/tpotce/blob/master/docker/elk/filebeat/filebeat.yml).

I choose `64299/tcp` for Logstash to listen to the request from Filebeat, please check your firewall policy. Also, like my previous version, all my servers are connected by WireGuard VPN and transform data through the VPN tunnel.

## New Issue
### Filebeat "input" Field Name Conflict
Beats fields conform to the [Elastic Common Schema (ECS)](https://www.elastic.co/guide/en/ecs/current/index.html), which has a field name called "input" as an object. Since "input" is an important field for many honeypots as string type, I modify the default `fields.yml` file to overwrite the "input" field schema. Details can be check at this commit: https://github.com/TheoKlein/tpotce/commit/162c1aac65be154d9dcad93da6fb73f5d1863e6c

I think this is not a great solution but it works. If anyone has a better way to solve this problem, please let me know.

### Logstash 7.0 Strict Field Reference
Start from Logstash 7.0, [field reference parser is more strict](https://www.elastic.co/guide/en/logstash/current/breaking-7.0.html#field-ref-strict).

Logstash will crash when your honeypot get the request like this:
```
curl -X POST http://<HONEYPOT_IP> -d "0x[]=test"
```

It will be logged by Tanner and dump the post data like this snippet:
```
...
"post_data": {
    "0x[]": "test"
}
...
```

There is an open issue on [GitHub](https://github.com/elastic/logstash/issues/11608
) to discuss this problem. I have no choice but to modify the log format from Tanner, convert the dictionary post data to URL encoded string.
```
...
"post_data": "0x%5B%5D%3Dtest"
...
```
You can take a look at here https://github.com/TheoKlein/tanner/blob/master/tanner/reporting/log_local.py#L12

These two issues are the major problem I meet. For all modifications, you can check at here: https://github.com/telekom-security/tpotce/compare/1afbb8...TheoKlein:fe7b540

## Deploy Your Distributed Honeypot System
> Attention: My forked repository also modifies some other settings, please check the comparison before you install from my repository.

On each sensor server:
```sh
$ git clone https://github.com/TheoKlein/tpotce
$ cp tpotce/docker/elk/filebeat/fi* /opt/

# Modify your central collector server's IP
$ vim /opt/filebeat.yml

# Follow the official instruction to install as "NEXTGEN" type
```

On central collector server:
```sh
$ git clone https://github.com/TheoKlein/tpotce
$ cp tpotce/docker/elk/logstash/dist/logstash_with_filebeat.conf /opt/logstash.conf

# Follow the official instruction to install as "COLLECTOR" type
```

## Conclusion
Right now my distributed honeypot system has 5 sensor servers, 1 VPN gateway server, and 1 central collector server. Except for the central collector server, everything else is a rented VPS, which costs me $30 a month in total. It's a perfectly acceptable price for me :)