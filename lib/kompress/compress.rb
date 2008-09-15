module Kompress
  module Compress
    def compress_using(preset)
      raise Kompress::NoConfigurationError if (!Kompress::Config.presets[preset])
    end
  end
end