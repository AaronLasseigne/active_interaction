source 'https://rubygems.org'

gemspec path: '..'

gem 'activemodel', '~> 5.2.0'
gem 'activerecord', '~> 5.2.0'
if defined?(JRUBY_VERSION)
  gem 'activerecord-jdbcsqlite3-adapter', '52.3'
else
  gem 'sqlite3', '~> 1.3.13'
end
