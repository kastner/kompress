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
end

describe "A real job" do
  setup do
    Kompress::Config.write do |k|
      k.command :ffmpeg => "/Library/Application\\ Support/Techspansion/vh131ffmpeg"
      k.setting :directory => "/tmp"
      k.setting :qt_faststart => "/usr/bin/qt-faststart"
      
      k.preset :rad => {
        :command => %Q{:ffmpeg -y -i :input_file :temp_file 2>> :status_file ; echo done > :done_file},
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
    @job.frame_rate.should == 44.92
  end
  
  it "should know duration" do
    @job.duration.should == 6.0
  end
  
  it "should know total frames" do
    @job.total_frames.should == 269.52
  end

  it "should know it's current frame #" do
    @job.current_frame.should == 157
  end
end
