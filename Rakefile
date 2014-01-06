require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new
Rubocop::RakeTask.new

task default: %w(spec rubocop)
