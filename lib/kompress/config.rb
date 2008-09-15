module Kompress
  module Config
    extend self
    
    attr_reader :commands, :settings
    
    def presets
      @presets || {}
    end
    
    def write
      yield self
    end
    
    def command(hash)
      @commands ||= {}
      @commands.merge! hash
    end
    
    def setting(hash)
      @settings ||= {}
      @settings.merge! hash
    end
    
    def preset(hash)
      @presets ||= {}
      hash.each do |k, v|
        @presets[k] = Preset.new(k, v)
      end
    end
    
    class Preset
      attr_reader :name
      attr_accessor :options
      
      def initialize(name, options = {})
        @command = options.delete(:command) || ""
        @name = name.to_s
        @options = options
      end
      
      def command
        kc = Kompress::Config
        replacements = kc.settings.merge(kc.commands.merge(@options))
        @command.gsub(/:\w+/) {|s| replacements[s.gsub(/^:/,'').intern] || s }
      end
      
      def description
        @options[:description] || @name
      end
    end
  end
end