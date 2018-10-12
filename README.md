# Logstash SFTP Plugin

<!--[![Travis Build Status](https://travis-ci.org/yuxuanh/logstash-input-sftp.svg)](https://travis-ci.org/yuxuanh/logstash-input-sftp)-->

This is a plugin for [Logstash](https://github.com/elastic/logstash).

It is fully free and fully open source. The license is Apache 2.0, meaning you are pretty much free to use it however you want in whatever way.

## Usage

### 1.Build your plugin gem
```sh
gem build logstash-input-sftp.gemspec
```

### 2.Install Plugin From Logstash home
put logstash-input-sftp-0.0.1.gem at logstash home
```sh
wget https://rubygems.org/downloads/net-ssh-5.0.2.gem
wget https://rubygems.org/downloads/net-sftp-2.1.2.gem
mkdir logstash
mv *.gem logstash/
zip -r logstash-input-sftp.zip logstash
bin/logstash-plugin install file:///absolute/path/to/logstash-input-sftp.zip
```
then you can see the plugin are under logstash_home/vendor/bundle/jruby/2.3.0/gems

### 3.Config file
```sh
input {
  sftp {
    username => "username"
    password => "optional_if_keyfile_path_exist"
    keyfile_path => "optional"
    remote_host => "localhost"
    port => 22
    remote_path => "/var/a.log"
    local_path => "/var/b.log"
    delimiter => "\n"
  }
}
output {
  stdout {
    codec => rubydebug
  }
}
```

## General Documentation

[logstash-input-example](https://github.com/logstash-plugins/logstash-input-example)
