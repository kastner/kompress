module Kompress
  module Config
    extend self
    
    def presets
      @presets || {}
    end
    
    def commands(command)
      @commands[command]
    end
    
    def write
      yield self
    end
    
    def command(hash)
      @commands ||= {}
      @commands.merge! hash
    end
  end
end