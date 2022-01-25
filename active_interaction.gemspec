lib = File.expand_path('lib', __dir__)
$LOAD_PATH.push(lib) unless $LOAD_PATH.include?(lib)

require 'active_interaction/version'

Gem::Specification.new do |gem| # rubocop:disable Metrics/BlockLength
  gem.name = 'active_interaction'
  gem.version = ActiveInteraction::VERSION
  gem.licenses = %w[MIT]

  gem.summary = 'Manage application specific business logic.'
  gem.description = <<-'TEXT'
    ActiveInteraction manages application-specific business logic. It is an
    implementation of the command pattern in Ruby.
  TEXT
  gem.metadata = {
    'homepage_uri' => 'https://github.com/AaronLasseigne/active_interaction',
    'source_code_uri' => 'https://github.com/AaronLasseigne/active_interaction',
    'changelog_uri' => 'https://github.com/AaronLasseigne/active_interaction/blob/master/CHANGELOG.md',
    'rubygems_mfa_required' => 'true'
  }

  gem.required_ruby_version = '>= 2.5'

  {
    'Aaron Lasseigne' => 'aaron.lasseigne@gmail.com',
    'Taylor Fausak' => 'taylor@fausak.me'
  }.tap do |hash|
    gem.authors = hash.keys
    gem.email = hash.values
  end

  gem.files = %w[CHANGELOG.md CONTRIBUTING.md LICENSE.md README.md] +
    Dir.glob(File.join('lib', '**', '*.rb')) +
    Dir.glob(File.join('lib', 'active_interaction', 'locale', '*.yml'))
  gem.test_files = Dir.glob(File.join('spec', '**', '*.rb'))

  gem.add_dependency 'activemodel', '>= 5', '< 8'
  gem.add_dependency 'activesupport', '>= 5', '< 8'

  {
    'actionpack' => [],
    'activerecord' => [],
    'benchmark-ips' => ['~> 2.7'],
    'kramdown' => ['~> 2.1'],
    'rake' => ['~> 13.0'],
    'rspec' => ['~> 3.5'],
    'rubocop' => ['~> 1.24.0'],
    'rubocop-rake' => ['~> 0.6.0'],
    'rubocop-rspec' => ['~> 2.7.0'],
    'sqlite3' => [],
    'yard' => ['~> 0.9']
  }.each do |name, versions|
    gem.add_development_dependency name, *versions
  end
end
