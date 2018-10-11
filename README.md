# Logstash SFTP Plugin

[![Travis Build Status](https://travis-ci.org/yuxuanh/logstash-input-sftp.svg)](https://travis-ci.org/yuxuanh/logstash-input-sftp)

This is a plugin for [Logstash](https://github.com/elastic/logstash).

It is fully free and fully open source. The license is Apache 2.0, meaning you are pretty much free to use it however you want in whatever way.

## Usage

### 1.Build your plugin gem
gem build logstash-input-sftp.gemspec

### 2.Install Plugin From Logstash home
```sh
bin/logstash-plugin install net-ssh
```
```sh
bin/logstash-plugin install net-sftp
```
```sh
bin/logstash-plugin install logstash-input-sftp
```


## General Documentation

[logstash-input-example](https://github.com/logstash-plugins/logstash-input-example)
