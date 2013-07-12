lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'active_interaction/version'

Gem::Specification.new do |spec|
  spec.name = 'active_interaction'
  spec.version = ActiveInteraction::VERSION.to_s
  spec.summary = 'Manage application specific business logic.'
  spec.description = spec.summary
  spec.homepage = 'https://github.com/orgsync/active_interaction'
  spec.authors = ['Aaron Lasseigne', 'Taylor Fausak']
  spec.email = ['aaron.lasseigne@gmail.com', 'taylor@fausak.me']
  spec.license = 'MIT'

  # Files
  spec.require_path = 'lib'
  spec.test_files = Dir['spec/**/*.rb']
  spec.files = spec.test_files + Dir['lib/**/*.rb'] + %w(CHANGELOG.md LICENSE.txt README.md)

  # Dependencies
  spec.required_ruby_version = '>= 1.9.3'

  spec.add_dependency 'activemodel', '>= 3.0.0', '~> 4.0'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'coveralls', '~> 0.6'
  spec.add_development_dependency 'guard-rspec', '~> 3.0'
  spec.add_development_dependency 'kramdown', '~> 1.1'
  spec.add_development_dependency 'rake', '~> 10.1'
  spec.add_development_dependency 'rb-fsevent', '~> 0.9'
  spec.add_development_dependency 'rspec', '~> 2.14'
  spec.add_development_dependency 'yard', '~> 0.8'
end
