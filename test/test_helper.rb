begin
  require 'test/spec'
rescue LoadError
  require 'rubygems'
  require 'test/spec'
end

begin
  require 'autotest/redgreen'
  require 'autotest/growl'
rescue
end

require File.dirname(__FILE__) + "/../lib/kompress"