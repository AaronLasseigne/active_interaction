source 'https://rubygems.org'

gemspec path: '..'

gem 'activemodel', '~> 6.1.0.rc1'
gem 'activerecord', '~> 6.1.0.rc1'
unless defined?(JRUBY_VERSION) # rubocop:disable Style/IfUnlessModifier
  gem 'sqlite3', '~> 1.4.1'
end
