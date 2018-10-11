# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/inputs/sftp"

describe LogStash::Inputs::SFTP do

  it "should register" do
    sftp_configuration = {:host => "127.0.0.1",
                          :remote_path => "/dev/null",
                          :local_path => "/dev/null"}
    input = LogStash::Plugin.lookup("input", "sftp").new(sftp_configuration)

    # register will try to load jars and raise if it cannot find jars or if org.apache.log4j.spi.LoggingEvent class is not present
    expect {input.register}.to_not raise_error
  end

  it "should raise exception" do
    input = LogStash::Plugin.lookup("input", "sftp").new
    expect { input.register }.to raise_error(ArgumentError)
  end

  context "when interrupting the plugin" do

    it_behaves_like "an interruptible input plugin" do
      let(:config) { { "interval" => 120 } }
    end
  end

end
