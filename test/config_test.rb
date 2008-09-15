require File.dirname(__FILE__) + '/test_helper'

describe "Kompress" do
  it "should raise an error if no configuration supplied" do
    lambda { Kompress.compress_using(:awesome) }.should.raise Kompress::NoConfigurationError
  end
end

describe "Kompress::Config" do
  setup do
    Kompress::Config.write do |k|
      k.command :ffmpeg => "/usr/bin/ffmpeg"
    end
  end
  
  it "should map commands to locations" do
    Kompress::Config.commands(:ffmpeg).should == "/usr/bin/ffmpeg"
  end
end