# Disable code coverage for JRuby because it always reports 0% coverage.
if RUBY_ENGINE != 'jruby'
  require 'coveralls'
  Coveralls.wear!
end

require 'i18n'
if I18n.config.respond_to?(:enforce_available_locales)
  I18n.config.enforce_available_locales = true
end

require 'active_interaction'

Dir['./spec/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run_including :focus
end
