---
title: Deploy A Distributed T-Pot System For Personal Research In Budget
metaAlignment: center
coverMeta: out
thumbnailImagePosition: left
date: 2019-11-26 10:47:22
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
A distributed honeypot system based on [T-Pot 19.03.1](https://github.com/dtag-dev-sec/tpotce)
<!-- more -->
Back to T-Pot 17.10, 2017. That was the first time I searched for an open-source honeypot system solution and it got my attention. It's a great project that combined many honeypots into one system with ELK (Elasticsearch / Logstash / Kibana), which is a powerful log search and visualizes software.

After 2 years, now I have an opportunity to build my honeypot system for personal research. My goal is simple, I want a distributed honeypot system that allowed me to deploy the honeypot at different locations then send back the data to one central server. T-Pot provides an easy way to customize the honeypot you want by just editing the docker-compose file.

Here is my plan, all honeypot sensors (only install honeypots and Logstash container) should be installed on any VPS for $5 per instance (1GB RAM / 1 CPU / 25 GB SSD / 1T Bandwidth ), such as DigitalOcean or Vultr. The central server in my local network only installs Elasticsearch, Kibana and other necessary services provided by T-Pot. Because the central server is not exposed to the public network, I choose WireGuard as my VPN software to deal with data transfer problems between each honeypot server including the central server by creating a private tunnel.

All my honeypot servers have followed the installation from T-Pot [Post-Install User](https://github.com/dtag-dev-sec/tpotce#postinstall) but only customize the container I want and Logstash with my config file.

The services on the central collector:
- Elasticsearch
- Kibana
- Elasticsearch-head
- nginx

The services on sensor server:
- Adbhoney
- Ciscoasa
- Conpot IEC104
- Conpot guardian_ast
- Conpot ipmi
- Conpot kamstrup_382
- Cowrie
- Dionaea
- Elasticpot
- Heralding
- Honeytrap
- Mailoney
- Medpot
- Rdpy
- Snare / Tanner
- P0f
- Suricata
- Logstash

The reason why I deploy a central server is that Elasticsearch needs more hardware resources, especially RAM. So I came out with this idea to modify T-Pot sensor server only collect the honeypots log and send back data with Logstash. By the advantage of the SSD VPS server, the speed of swapping is enough to run all these honeypots and Logstash with only 1 GB RAM and 3 GB swap (Totaly 4GB RAM is enough).

All these service's docker-compose settings can be found [here](https://github.com/dtag-dev-sec/tpotce/tree/master/etc/compose), you can modify by yourself.

The most important customize on the sensor server is Logstash's config file. We need to change the output to our central server through WireGuard tunnel. Therefore, I placed the custom config file at /opt/logstash.conf and mount to container's volume:
```yml
logstash:
    container_name: logstash
    restart: always

    # Since we don't have elasticsearch on sensor server,
    # the depends_on option can be removed.

    # depends_on:
    #     elasticsearch:
    #     condition: service_healthy
    
    env_file:
        - /opt/tpot/etc/compose/elk_environment
    image: "dtagdevsec/logstash:1903"
    volumes:
        - /opt/logstash.conf:/etc/logstash/conf.d/logstash.conf:ro  # mount custom logstash.conf
        - /data:/data
```

After T-Pot complete the whole installation, we can now install WireGuard on each server and set the right config. On the central server, make sure you forward 0.0.0.0:64298 to 127.0.0.1:64298 because the default docker-compose setting only listen on localhost for security issue. Double check your firewall or iptables setting to prevent elasticsearch service expose to anyone if your central server is public.

It works! Currently, I deployed 4 sensor servers in different countries. To add a new sensor server, just install on a new server with your customize T-Pot sensor, setup the WireGuard connection, and wait for the bunch of data to send back to the central server. It costs me $25 per month for 5 VPS (4 sensors + 1 gateway server) which I think is meets my expectations. Depends on your budget, the number of sensor servers can be decided by yourself.

Now I get a bunch of binaries and logs, time to do some research :)