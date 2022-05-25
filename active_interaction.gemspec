# frozen_string_literal: true

require_relative 'lib/active_interaction/version'

Gem::Specification.new do |spec| # rubocop:disable Metrics/BlockLength
  spec.name = 'active_interaction'
  spec.version = ActiveInteraction::VERSION
  spec.license = 'MIT'

  {
    'Aaron Lasseigne' => 'aaron.lasseigne@gmail.com',
    'Taylor Fausak' => 'taylor@fausak.me'
  }.tap do |hash|
    spec.authors = hash.keys
    spec.email = hash.values
  end

  spec.summary = 'Manage application specific business logic.'
  spec.description = <<~'TEXT'
    ActiveInteraction manages application-specific business logic. It is an
    implementation of what are called service objects, interactors, or the
    command pattern. No matter what you call it, its built to work seamlessly
    with Rails.
  TEXT
  spec.homepage = 'https://github.com/AaronLasseigne/active_interaction'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.required_ruby_version = '>= 2.7'

  spec.files =
    %w[CHANGELOG.md CONTRIBUTING.md LICENSE.md README.md] +
    Dir.glob(File.join('lib', '**', '*.rb')) +
    Dir.glob(File.join('lib', 'active_interaction', 'locale', '*.yml'))
  spec.test_files = Dir.glob(File.join('spec', '**', '*.rb'))

  spec.add_dependency 'rails', '>= 5.2', '< 8'

  {
    'kramdown' => ['~> 2.1'],
    'rake' => ['~> 13.0'],
    'rspec' => ['~> 3.5'],
    'rubocop' => ['~> 1.26.1'],
    'rubocop-rake' => ['~> 0.6.0'],
    'rubocop-rspec' => ['~> 2.9.0'],
    'sqlite3' => [],
    'yard' => ['~> 0.9']
  }.each do |name, versions|
    spec.add_development_dependency name, *versions
  end
end
