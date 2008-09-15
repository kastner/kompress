Gem::Specification.new do |s|
  s.name = "kompress"
  s.version = "0.0.1"
  s.date = "2008-09-14"
  s.summary = "Kompress - kompress videos and see progress"
  s.email = "kastner@gmail.com"
  s.homepage = "http://github.com/kastner/kompress.git"
  s.description = "Kompress - kompress videos and see progress"
  s.has_rdoc = false
  s.require_path = '.'
  s.authors = ["Erik Kastner"]
  s.files = ["lib/kompress.rb", "README.mkdn", "lib/kompress/compress.rb",
             "lib/kompress/config.rb", "lib/kompress/exceptions.rb",
             "test/test_helper.rb", "test/config_test.rb"]
  s.rdoc_options = ["--main", "README.mkdn"]
end