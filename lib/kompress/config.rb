module Kompress
  module Config
    extend self
    
    def presets
      @presets || {}
    end
  end
end