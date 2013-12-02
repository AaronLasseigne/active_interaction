require 'active_model'

require 'active_interaction/version'
require 'active_interaction/errors'

require 'active_interaction/modules/active_model'
require 'active_interaction/modules/core'
require 'active_interaction/modules/method_missing'
require 'active_interaction/modules/overload_hash'
require 'active_interaction/modules/validation'

require 'active_interaction/filter'
require 'active_interaction/filters'
require 'active_interaction/filters/abstract_date_time_filter'
require 'active_interaction/filters/abstract_numeric_filter'
require 'active_interaction/filters/array_filter'
require 'active_interaction/filters/boolean_filter'
require 'active_interaction/filters/date_filter'
require 'active_interaction/filters/date_time_filter'
require 'active_interaction/filters/file_filter'
require 'active_interaction/filters/float_filter'
require 'active_interaction/filters/hash_filter'
require 'active_interaction/filters/integer_filter'
require 'active_interaction/filters/model_filter'
require 'active_interaction/filters/string_filter'
require 'active_interaction/filters/symbol_filter'
require 'active_interaction/filters/time_filter'

require 'active_interaction/base'

I18n.backend.load_translations(
  Dir.glob(File.join(%w(lib active_interaction locale *.yml)))
)

# @since 0.1.0
module ActiveInteraction end
