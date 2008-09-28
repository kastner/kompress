module Kompress
  class Job
    attr_accessor :options, :job_id, :input_file, :container_type, :start_time, :thumb_type
    attr_accessor :state

    def self.from_file(file)
      rpls = YAML.load(open(file).read)
      job = new
      job.instance_eval do
        @state = :running
        @job_id = rpls[:job_id]
        @container_type = rpls[:container_type]
        @input_file = rpls[:input_file]
        @start_time = rpls[:start_time]
        @thumb_type = rpls[:thumb_type]
        @options = rpls
        def replacements; @options; end
      end
      job
    end
    
    def self.from_preset(preset, input_file, container_type = "mp4", thumb_type = "jpg")
      config_preset = Kompress::Config.presets[preset]
      raise Kompress::NoConfigurationError unless config_preset
      
      job = new
      job.fill(preset, config_preset.command, input_file, container_type, thumb_type, config_preset.options)
      job
    end
    
    def fill(name, command, input_file, container_type, thumb_type, options)
      @start_time = Time.now
      @state = :pending
      @options, @input_file, @command = options, input_file, command
      @thumb_type = thumb_type
      @container_type = container_type
      @job_id = Time.now.to_i.to_s + "-" + name.to_s
    end
    
    def kc_replacements
      kc = Kompress::Config
      (kc.settings || {}).merge((kc.commands || {}).merge(@options))
    end
    
    def replacements
      rpl = {}
      rpl[:job_id] = @job_id
      rpl[:container_type] = @container_type
      rpl[:thumb_type] = @thumb_type
      rpl[:input_file] = @input_file
      rpl[:start_time] = @start_time
      rpl.merge(kc_replacements)
    end
    
    def command
      substitute(@command, replacements)
    end
    
    def post_command
      substitute(options[:post_command], replacements)
    end
    
    def file_type_regexp
      /\.(#{Kompress::FileTypes.join("|")})/i
    end
    
    def temp_file
      input_file.gsub(file_type_regexp, ".tmp.#{container_type}")
    end
    
    def output_file
      input_file.gsub(file_type_regexp, ".#{container_type}")
    end
    
    def thumb_file
      input_file.gsub(file_type_regexp, ".#{thumb_type}")
    end
    
    def substitute(string, subs)
      string.gsub(/:\w+/) do |s|
        s.gsub!(/^:/, '')
        if respond_to?(s)
          send(s)
        else
          subs[s.gsub(/^:/,'').intern] || s
        end
      end
    end
    
    def status_file
      kc_replacements[:directory] + "/kompress-#{@job_id}"
    end

    def state_file
      kc_replacements[:directory] + "/kompress-#{@job_id}.state"
    end
    
    def done_file
      kc_replacements[:directory] + "/kompress-#{@job_id}.done"
    end

    def status_contents
      open(status_file).read
    end
    
    def frame_rate
      @frame_rate ||= status_contents[@options[:frame_rate_regexp], 1].to_f.ceil
    end
    
    def duration
      @duration ||= begin
        d = status_contents[@options[:duration_regexp], 1]
        if (d.match(/:/))
          p = d.split(/:/)
          p[-1].to_f + p[-2].to_f * 60 + p[-3].to_f * 60 * 60
        else
          d.to_f
        end
      end
    end
    
    def total_frames
      (duration * frame_rate).to_i
    end
    
    def current_frame
      return 0 unless @state == :running
      matches = status_contents.scan(@options[:current_frame_regexp])
      
      if (File.exists?(done_file))
        @state = :done
        finalize
      end
      
      matches.last[0].to_i
    end
    
    def finalize
      `#{post_command}` if post_command
      cleanup
    end
    
    def cleanup
      File.unlink(state_file)
      File.unlink(status_file)
      File.unlink(done_file)
      File.unlink(temp_file)
    end
    
    def write_state_to_disk
      File.open(state_file, "w") do |f|
        f.puts replacements.to_yaml
      end
    end
    
    def go
      @state = :running
      write_state_to_disk
      Thread.new do
        `#{command}`
      end
      
      while (!File.exists?(status_file)); sleep 0.2; end
    end
  end
end
