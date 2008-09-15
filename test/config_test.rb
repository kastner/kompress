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
      k.setting :directory => "/t"
      
      k.preset :test => {
        :command => ":ffmpeg go > :directory"
      }
    end
  end
  
  it "should map commands to locations" do
    Kompress::Config.commands[:ffmpeg].should == "/usr/bin/ffmpeg"
  end

  it "should map settings" do
    Kompress::Config.settings[:directory].should == "/t"
  end
  
  it "should substitue placeholders" do
    Kompress::Config.presets[:test].command.should == "/usr/bin/ffmpeg go > /t"
  end
end

describe "Kompress::Config::Preset" do
  setup do
    @p = Kompress::Config::Preset.new(:rad, {:description => "Rad testing preset"})
  end
  
  it "should have a description" do
    @p.description.should == "Rad testing preset"
  end
  
  it "should use the name as a description if none provided" do
    @p.options.delete(:description)
    @p.description.should == "rad"
  end
end