# coding: utf-8

lib = File.expand_path('lib', File.dirname(__FILE__))
$LOAD_PATH.push(lib) unless $LOAD_PATH.include?(lib)

require 'active_interaction/version'

Gem::Specification.new do |gem|
  gem.name = 'active_interaction'
  gem.version = ActiveInteraction::VERSION
  gem.summary = 'Manage application specific business logic.'
  gem.description = <<-'TEXT'
    ActiveInteraction manages application-specific business logic. It is an
    implementation of the command pattern in Ruby.
  TEXT
  gem.homepage = 'http://devblog.orgsync.com/active_interaction/'
  gem.licenses = %w[MIT]

  gem.required_ruby_version = '>= 1.9.3'

  {
    'Aaron Lasseigne' => 'aaron.lasseigne@gmail.com',
    'Taylor Fausak' => 'taylor@fausak.me'
  }.tap do |hash|
    gem.authors = hash.keys
    gem.email = hash.values
  end

  gem.files = %w[CHANGELOG.md CONTRIBUTING.md LICENSE.txt README.md] +
    Dir.glob(File.join('lib', '**', '*.rb')) +
    Dir.glob(File.join('lib', 'active_interaction', 'locale', '*.yml'))
  gem.test_files = Dir.glob(File.join('spec', '**', '*.rb'))

  gem.add_dependency 'activemodel', '>= 3.2', '<5'

  {
    'bundler' => '~> 1.9',
    'coveralls' => '~> 0.8',
    'guard-rspec' => '~> 4.5',
    'guard-rubocop' => '~> 1.2',
    'kramdown' => '~> 1.7',
    'rake' => '~> 10.4',
    'rspec' => '~> 3.2',
    'rubocop' => '~> 0.30',
    'yard' => '~> 0.8'
  }.each do |name, version|
    gem.add_development_dependency name, version
  end

  if RUBY_ENGINE == 'rbx'
    {
      'parser' => '~> 2.1',
      'racc' => '~> 1.4',
      'rubinius-coverage' => '~> 2.0',
      'rubysl' => '~> 2.1',
      'rubysl-test-unit' => '~> 2.0'
    }.each do |name, version|
      gem.add_development_dependency name, version
    end
  end
end
