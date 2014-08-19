# coding: utf-8

guard 'rspec', cmd: 'bundle exec rspec', all_after_pass: false do
  watch(/^spec\/.+_spec\.rb$/)
  watch(%r{^spec/support/.+\.rb$}) { 'spec' }
  watch(/^lib\/(.+)\.rb$/) { |m| "spec/#{m[1]}_spec.rb" }
end

guard 'rubocop', cmd: 'bundle exec rubocop', all_on_start: false do
  watch(/^spec\/.+_spec\.rb$/)
  watch(%r{^spec/support/.+\.rb$})
  watch(/^lib\/(.+)\.rb$/)
end
