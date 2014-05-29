require 'rake'

Gem::Specification.new do |s|
  s.name        = 'git_repo'
  s.version     = '0.0.0'
  s.date        = '2013-12-04'
  s.summary     = "Reads git repos"
  s.description = "More to come"
  s.authors     = ["Jeff Sember"]
  s.email       = 'jpsember@gmail.com'
  s.files = FileList['lib/**/*.rb',
                      'bin/*',
                      '[A-Z]*',
                      'test/**/*',
                      ]
  s.add_runtime_dependency 'js_base'
  s.homepage = 'http://www.cs.ubc.ca/~jpsember'
  s.test_files  = Dir.glob('test/*.rb')
  s.license     = 'MIT'
end
