#Download base image ubuntu 16.04
FROM ubuntu:16.04 
MAINTAINER George Chilumbu

ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

# Set timezone
ENV TZ=Asia/Taipei
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set the working directory to /app
WORKDIR ~/

# Install some necessary software/tools  
RUN apt-get update && apt-get install -y \
    wget \
    less \
    vim \
    unzip \
    inetutils-ping \
    inetutils-tools \
    net-tools \
    dnsutils \
    software-properties-common \
    python-software-properties \
    ntp \
    rsyslog \
    curl

RUN apt-get upgrade -y

RUN add-apt-repository ppa:chris-lea/redis-server \
    && apt-get update \
    && apt-get install -y redis-server \
    redis-sentinel \
    && rm /etc/redis/redis.conf \
    && rm /etc/redis/sentinel.conf
   
COPY redis/redis.conf /etc/redis/redis.conf
COPY redis/sentinel.conf /etc/redis/sentinel.conf

RUN chown redis:redis -R /etc/redis

RUN mkdir -p /opt/redis/redis_dump
RUN chown redis:redis -R /opt/redis/redis_dump

## INSTALL and setup redis_exporter
RUN wget https://github.com/oliver006/redis_exporter/releases/download/v0.21.1/redis_exporter-v0.21.1.linux-amd64.tar.gz
RUN tar zxf redis_exporter-v0.21.1.linux-amd64.tar.gz -C /opt/

## INSTALL and setup onsul
RUN wget https://releases.hashicorp.com/consul/1.2.2/consul_1.2.2_linux_amd64.zip
RUN unzip consul_*
RUN rm consul_*
RUN mv consul /usr/local/bin
RUN mkdir -p /etc/consul.d/scripts
RUN useradd -ms /bin/bash consul
RUN mkdir /var/consul
RUN chown consul:consul -R /var/consul

COPY consul/config.json /etc/consul.d
COPY consul/services.json /etc/consul.d
COPY consul/redis.sh /etc/consul.d/scripts
COPY consul/master.json /etc/consul.d/scripts
COPY consul/slave.json /etc/consul.d/scripts
COPY consul/consul.conf /etc/init

RUN chmod +x /etc/consul.d/scripts/redis.sh
