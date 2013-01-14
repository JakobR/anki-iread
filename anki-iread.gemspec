Gem::Specification.new do |s|
  s.name        = 'anki-iread'
  s.version     = '0.0.1'
  s.date        = '2013-01-14'
  #s.summary     = "Tools to help with Incremental Reading in Anki."
  s.description = "Tools to help with Incremental Reading in Anki."
  s.authors     = ["Jakob Rath"]
  s.email       = 'git@jakobrath.eu'
  s.homepage    = 'https://github.com/JakobR/anki-iread'

  s.files         = Dir["bin/*"] + Dir["{lib,test}/**/*.rb"] + %w[README.md Gemfile Gemfile.lock]
  s.test_files    = s.files.select { |path| path =~ /^test\/.*_test.rb/ }
  s.executables   = %w[anki-iread]
  s.require_paths = %w[lib]

  s.add_dependency 'bundler', '>= 1.2.3'
  s.add_dependency 'thor', '~> 0.16.0'
  s.add_dependency 'html-pipeline', '~> 0.0.6'
  s.add_dependency 'mime-types', '~> 1.19'
end
