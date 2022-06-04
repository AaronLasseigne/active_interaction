require 'i18n'
I18n.config.enforce_available_locales = true if I18n.config.respond_to?(:enforce_available_locales)

require 'active_interaction'

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run_including :focus

  config.before(:suite) do
    if ::ActiveRecord.respond_to?(:index_nested_attribute_errors)
      ::ActiveRecord.index_nested_attribute_errors = false
    else
      ::ActiveRecord::Base.index_nested_attribute_errors = false
    end
  end
end
