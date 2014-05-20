# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'active_interaction/version'

Gem::Specification.new do |spec|
  spec.name = 'active_interaction'
  spec.version = ActiveInteraction::VERSION.to_s
  spec.summary = 'Manage application specific business logic.'
  spec.description = spec.summary
  spec.homepage = 'http://orgsync.github.io/active_interaction/'
  spec.authors = ['Aaron Lasseigne', 'Taylor Fausak']
  spec.email = %w[aaron.lasseigne@gmail.com taylor@fausak.me]
  spec.license = 'MIT'

  # Files
  spec.require_path = 'lib'
  spec.test_files = Dir['spec/**/*.rb']
  spec.files = Dir['lib/**/*.rb'] + spec.test_files + %w[
    CHANGELOG.md
    LICENSE.txt
    README.md
  ] + Dir['lib/active_interaction/locale/**/*.yml']

  # Dependencies
  spec.required_ruby_version = '>= 1.9.3'

  spec.add_dependency 'activemodel', '>= 3.2', '< 5'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'coveralls', '~> 0.7'
  spec.add_development_dependency 'guard-rspec', '~> 4.2'
  spec.add_development_dependency 'guard-rubocop', '~> 1.1'
  spec.add_development_dependency 'rake', '~> 10.3'
  spec.add_development_dependency 'rdoc', '~> 4.1'
  spec.add_development_dependency 'rubocop', '0.21.0'
  spec.add_development_dependency 'yard', '~> 0.8'

  if RUBY_ENGINE == 'rbx'
    spec.add_development_dependency 'parser', '~> 2.1'
    spec.add_development_dependency 'racc', '~> 1.4'
    spec.add_development_dependency 'rubinius-coverage', '~> 2.0'
    spec.add_development_dependency 'rubysl', '~> 2.0'
    spec.add_development_dependency 'rubysl-test-unit', '~> 2.0'
  end
end
