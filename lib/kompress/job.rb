module Kompress
  class Job
    attr_reader :options, :job_id, :input_file, :container_type
    attr_accessor :state
    
    def self.from_preset(preset, input_file, container_type = "mp4")
      config_preset = Kompress::Config.presets[preset]
      raise Kompress::NoConfigurationError unless config_preset
      
      new(preset, config_preset.command, input_file, container_type, config_preset.options)
    end
    
    def initialize(name, command, input_file, container_type, options)
      @state = :pending
      @options, @input_file, @command = options, input_file, command
      @container_type = container_type
      @job_id = Time.now.to_i.to_s + "-" + name.to_s
    end
    
    def kc_replacements
      kc = Kompress::Config
      kc.settings.merge(kc.commands.merge(@options))
    end
    
    def replacements
      rpl = {}
      rpl[:job_id] = @job_id
      rpl.merge(kc_replacements)
    end
    
    def command
      substitute(@command, replacements)
    end
    
    def post_command
      substitute(options[:post_command], replacements)
    end
    
    def temp_file
      input_file.gsub(/\.(mov|avi|mp4|flv|wmv)$/, ".tmp.#{container_type}")
    end
    
    def output_file
      input_file.gsub(/\.(mov|avi|mp4|flv|wmv)$/, ".#{container_type}")
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
    
    def done_file
      kc_replacements[:directory] + "/kompress-#{@job_id}.done"
    end

    def status_contents
      open(status_file).read
    end
    
    def frame_rate
      @frame_rate ||= status_contents[@options[:frame_rate_regexp], 1].to_f
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
      duration * frame_rate
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
      system(post_command) if post_command
      cleanup
    end
    
    def cleanup
      File.unlink(status_file)
      File.unlink(done_file)
      File.unlink(temp_file)
    end
    
    def go
      @state = :running
      Thread.new do
        system command
      end
      
      while (!File.exists?(status_file)); sleep 0.2; end
    end
  end
end
