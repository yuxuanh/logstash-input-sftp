# encoding: utf-8
require "concurrent"
require "logstash/inputs/base"
require "logstash/inputs/file"
require "logstash/namespace"
require "stud/interval"
require "net/sftp"
require "rufus/scheduler"
require "date"

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
  config :schedule, :validate => :string

  public
  def register
    @logger.info("Registering SFTP Input",
             :username => @username, :password => @password,
             :remote_host => @remote_host, :port => @port,
             :remote_path => remote_path, :local_path => @local_path,
             :schedule => @schedule)
  end # def register

  def run(queue)
    if @schedule
      @scheduler = Rufus::Scheduler.new(:max_work_threads => 1)
      @scheduler.cron @schedule do
        process(queue)
      end

      @scheduler.join
    else
      process(queue)
    end
  end # def run

  def stop
    @scheduler.shutdown(:wait) if @scheduler
  end # def stop

  def process(queue)
    if @remote_path.include?('{today}')
      d = DateTime.now
      @remote_path.gsub!('{today}', d.strftime("%Y%m%d"))
    end

    @logger.info("Prepare to download #{remote_host}:#{remote_path} to #{local_path}")
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
      @logger.info("#{local_path} has processed, now waiting #{schedule}, then it will download and process again")
  end # def process
end # class LogStash::Inputs::Example
