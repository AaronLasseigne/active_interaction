# coding: utf-8

require 'coveralls'
Coveralls.wear!

require 'i18n'
if I18n.config.respond_to?(:enforce_available_locales)
  I18n.config.enforce_available_locales = true
  I18n.config.available_locales = %w[en hsilgne pt-BR]
end

require 'active_interaction'

Dir['./spec/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run_including :focus
end
