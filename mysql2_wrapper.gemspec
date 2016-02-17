# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mysql2_wrapper/version'

Gem::Specification.new do |spec|
  spec.name          = 'mysql2_wrapper'
  spec.version       = Mysql2Wrapper::VERSION
  spec.authors       = ['David Marchante']
  spec.email         = ['davidmarchan@gmail.com']

  spec.summary       = 'Simple mysql2 wrapper for common tasks'
  # spec.description   = 'TODO: Write a longer description or delete this line.'
  spec.homepage      = 'https://github.com/iovis9/mysql2_wrapper'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'mysql2', '~> 0.4'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'factory_girl'
  spec.add_development_dependency 'ruby-prof'
  spec.add_development_dependency 'pry'
end
