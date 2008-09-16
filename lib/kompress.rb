$:.unshift(File.dirname(__FILE__))

require 'yaml'

require 'kompress/compress'
require 'kompress/config'
require 'kompress/exceptions'
require 'kompress/job'

module Kompress
  extend Compress
end