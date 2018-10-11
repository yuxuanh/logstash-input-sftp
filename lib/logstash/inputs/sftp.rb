# encoding: utf-8
require "concurrent"
require "logstash/inputs/base"
require "logstash/inputs/file"
require "logstash/namespace"
require "stud/interval"
require "net/sftp"

# This is for logstash to sftp download file and parse
# The config should look like this:
#
# ----------------------------------
# input {
#   sftp {
#     username => "username"
#     password => "password"
#     remote_host => "localhost"
#     port => 22
#     remote_path => "/var/a.log"
#     local_path => "/var/b.log"
#   }
# }
#
# output {
#   stdout {
#     codec => rubydebug
#   }
# }
# ----------------------------------

class LogStash::Inputs::SFTP < LogStash::Inputs::Base
  config_name "sftp"

  # If undefined, Logstash will complain, even if codec is unused.
  default :codec, "plain"

 # Login credentials on SFTP server.
  config :username, :validate => :string, :default => "username"
  config :password
  config :keyfile_path
  config :delimiter, :default => "\n"

  # SFTP server hostname (or ip address)
  config :remote_host, :validate => :string, :required => true
  # and port number.
  config :port, :validate => :number, :default => 22

  # Remote SFTP path and local path
  config :remote_path, :validate => :string, :required => true
  config :local_path, :validate => :string, :required => true

  # Interval to pull remote data (in seconds).
  config :interval, :validate => :number, :default => 60

  public
  def register
    @logger.info("Registering SFTP Input",
             :username => @username, :password => @password,
             :remote_host => @remote_host, :port => @port,
             :remote_path => remote_path, :local_path => @local_path,
             :interval => @interval)
  end # def register

  def run(queue)
    # we can abort the loop if stop? becomes true
    while !stop?
      if @password.nil?
        Net::SFTP.start(@remote_host, @username, :keys => @keyfile_path) do |sftp|
          sftp.download!(@remote_path, @local_path)
        end #download
      else 
        Net::SFTP.start(@remote_host, @username, :password => @password) do |sftp|
          sftp.download!(@remote_path, @local_path)
        end #download
      end
      @logger.info("#{remote_host} : #{remote_path} has downloaded to #{local_path}")

      fh = open @local_path
      content = fh.read
      fh.close
      values=content.split(@delimiter)
      values.each do |value|
        event = LogStash::Event.new("message" => value)
        queue << event
      end #split
      @logger.info("#{local_path} has processed, now waiting #{interval}s, then it will download and process again")
      # because the sleep interval can be big, when shutdown happens
      # we want to be able to abort the sleep
      # Stud.stoppable_sleep will frequently evaluate the given block
      # and abort the sleep(@interval) if the return value is true
      Stud.stoppable_sleep(@interval) { stop? }
    end # loop
  end # def run

  def stop
    # nothing to do in this case so it is not necessary to define stop
    # examples of common "stop" tasks:
    #  * close sockets (unblocking blocking reads/accepts)
    #  * cleanup temporary files
    #  * terminate spawned threads
  end
end # class LogStash::Inputs::Example
