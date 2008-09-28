Gem::Specification.new do |s|
  s.name = "kompress"
  s.version = "0.0.4"
  s.date = "2008-09-14"
  s.summary = "Kompress - kompress videos and see progress"
  s.email = "kastner@gmail.com"
  s.homepage = "http://github.com/kastner/kompress.git"
  s.description = "Kompress - kompress videos and see progress"
  s.has_rdoc = false
  s.require_paths = ["lib"]
  s.authors = ["Erik Kastner"]
  s.files = ["kompress.gemspec", "lib/kompress", "lib/kompress/compress.rb",
             "lib/kompress/config.rb", "lib/kompress/exceptions.rb", "lib/kompress/job.rb",
             "lib/kompress.rb", "README.mkdn", "test/config_test.rb", "test/job-freeze",
             "test/job-status", "test/job_test.rb", "test/test_helper.rb"]

  s.rdoc_options = ["--main", "README.mkdn"]
end