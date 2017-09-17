require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new
RuboCop::RakeTask.new(:rubocop) do |task|
  task.options = ['--display-cop-names']
end

task default: %w[spec rubocop]
