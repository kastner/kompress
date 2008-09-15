require File.dirname(__FILE__) + '/test_helper'

describe "Kompress" do
  it "should raise an error if no configuration supplied" do
    lambda { Kompress.compress_using(:awesome) }.should.raise Kompress::NoConfigurationError
  end
end