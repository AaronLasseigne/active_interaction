# coding: utf-8

require 'coveralls'
Coveralls.wear!

require 'i18n'
I18n.config.enforce_available_locales = true

require 'active_interaction'

Dir['./spec/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run_including :focus
end
