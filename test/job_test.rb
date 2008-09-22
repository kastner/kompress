require File.dirname(__FILE__) + '/test_helper'

describe "Kompress::Job" do
  setup do
    Kompress::Config.write do |k|
      k.command :ffmpeg => "/usr/bin/ffmpeg"
      k.setting :directory => "/t"
      
      k.preset :test => {
        :command => ":ffmpeg go > :directory/:job_id"
      }
    end
    
    @job = Kompress::Job.from_preset(:test, "")
  end
  
  it "should substitue placeholders" do
    @job.command.should.match /\/ffmpeg/
  end
  
  it "should substitue job_id placeholder" do
    @job.command.should == "/usr/bin/ffmpeg go > /t/#{@job.job_id}"
  end
  
  it "should set a status file" do
    @job.status_file.should == "/t/kompress-#{@job.job_id}"
  end
  
  %w|mov wmv avi mp4 mpg mpeg|.each do |type|
    it "should replace .#{type} with .tmp.mp4" do
      @job.input_file = "x.#{type}"
      @job.temp_file.should == "x.tmp.mp4"
    end
  end
end

describe "A fake job" do
  setup do
    Kompress::Config.write do |k|
      k.preset :t => { :duration_regexp => /Duration: ([\d:]+)/ }
    end
    
    @job = Kompress::Job.from_preset(:t, "")
    @job.stubs(:status_contents).returns("Duration: 00:01:26.95, start: 0.0000")
  end
  
  it "should calculate seconds" do
    @job.duration.should == 86.0
  end
end

describe "A real job" do
  setup do
    Kompress::Config.write do |k|
      k.command :ffmpeg => "/Library/Application\\ Support/Techspansion/vh131ffmpeg"
      k.setting :directory => "/tmp"
      k.setting :qt_faststart => "/usr/bin/qt-faststart"
      
      k.preset :rad => {
        :command => %Q{:ffmpeg -y -i :input_file :temp_file 640x:width 2>> :status_file ; echo done > :done_file},
        :width => 480,
        :post_command => %Q{:qt_faststart :temp_file :output_file},
        :frame_rate_regexp => /0.0,,,,,Video,.*q=.*,([\d\.]+)$/,
        :duration_regexp => /Duration-(\d+)/,
        :current_frame_regexp => /frame=\s*(\d+)/
      }
      
      @job = Kompress::Job.from_preset(:rad, "~/Development/Ruby/test.mov")
      @job.state = :running
    end
    
    @job.stubs(:status_contents).returns(open(File.dirname(__FILE__) + '/job-status').read)
  end
  
  it "should know it's post_command" do
    @job.post_command.should == "/usr/bin/qt-faststart ~/Development/Ruby/test.tmp.mp4 ~/Development/Ruby/test.mp4"
  end
  
  it "should know frame rate" do
    # @job.frame_rate.should == 44.92
    @job.frame_rate.should == 45
  end
  
  it "should know duration" do
    @job.duration.should == 6.0
  end
  
  it "should know total frames" do
    @job.total_frames.should == 270
  end

  it "should know it's current frame #" do
    @job.current_frame.should == 157
    # puts @job.replacements.to_yaml
  end
  
  it "should have a start time" do
    @job.start_time.should.be.kind_of Time
  end
  
  it "should substitute fields without spaces" do
    @job.command.should =~ /640x480/
  end
  
  it "should be changable" do
    @job.options[:width] = 300
    @job.command.should =~ /640x300/
    @job.command.should.not =~ /640x480/
  end
end

describe "A frozen job" do
  setup do
    Kompress::Config.reset
    @job = Kompress::Job.from_file(File.dirname(__FILE__) + "/job-freeze")
    @job.stubs(:status_contents).returns(open(File.dirname(__FILE__) + '/job-status').read)
  end
  
  it "should have the right job id" do
    @job.job_id.should == "1221549341-rad"
  end
  
  it "should be able to fetch the duration" do
    @job.duration.should == 6.0
  end

  it "should have the right post_command" do
    @job.post_command.should == "/usr/bin/qt-faststart ~/Development/Ruby/test.tmp.mp4 ~/Development/Ruby/test.mp4"
  end
  
  it "should have a lame kc_replacements method" do
    @job.kc_replacements.should == @job.options
  end
  
  it "should be considered active" do
    @job.state.should == :running
  end
  
  it "should unfreeze the start time" do
    @job.start_time.year.should.be 2008
    @job.start_time.month.should.be 9
  end
end