# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'seismograph/version'

Gem::Specification.new do |spec|
  spec.name          = 'seismograph'
  spec.version       = Seismograph::VERSION
  spec.authors       = ['Brandon Croft', 'Matt Huggins']
  spec.email         = ['brandon@kapost.com', 'matt.huggins@kapost.com']
  spec.summary       = %q{Helper library to report stats and events to datadoghq}
  spec.description   = %q{Wraps dogstatsd-ruby with helpful conventions}
  spec.homepage      = 'https://github.com/kapost/seismograph'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'dogstatsd-ruby', '~> 1.5'

  spec.add_development_dependency 'pry-nav'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.2'
  spec.add_development_dependency 'rspec-its', '~> 1.2'
end
