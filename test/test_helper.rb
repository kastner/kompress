begin
  require 'test/spec'
  require 'mocha'
rescue LoadError
  require 'rubygems'
  require 'test/spec'
  require 'mocha'
end

begin
  require 'autotest/redgreen'
  require 'autotest/growl'
rescue
end

require File.dirname(__FILE__) + "/../lib/kompress"