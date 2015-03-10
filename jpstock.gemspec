# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jpstock/version'

Gem::Specification.new do |spec|
  spec.name          = 'jpstock'
  spec.version       = Jpstock::VERSION
  spec.authors       = ['utahta']
  spec.email         = ['labs.ninxit@gmail.com']
  spec.summary       = %q{JpStock is a Ruby library for extracting information about Japan stocks}
  spec.description   = %q{JpStock is a Ruby library for extracting information about Japan stocks}
  spec.homepage      = 'http://github.com/utahta/jpstock'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.2.0'

  spec.add_dependency 'nokogiri', '~> 1.6.6.2'
end
