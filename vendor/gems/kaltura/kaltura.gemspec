# require 'rake'

Gem::Specification.new do |s| 
  s.name = "kaltura-client"
  s.version = "1.0"
  s.date = '2012-04-16'
  s.author = "Kaltura Inc."
  s.email = "community@kaltura.com"
  s.homepage = "http://www.kaltura.com/"
  s.summary = "A gem implementation of Kaltura's Ruby Client"
  s.description = "A gem implementation of Kaltura's Ruby Client."
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.add_dependency('rest-client')
  s.add_development_dependency 'rake', '~> 10.0'
end
