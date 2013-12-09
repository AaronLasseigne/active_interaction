require 'coveralls'
Coveralls.wear!

require 'active_interaction'

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run_including :focus
end

I18n.config.enforce_available_locales = true
