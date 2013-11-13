require 'active_model'

require 'active_interaction/version'
require 'active_interaction/errors'
require 'active_interaction/overload_hash'
require 'active_interaction/filters'
require 'active_interaction/input'
require 'active_interaction/inputs/array_input'
require 'active_interaction/inputs/boolean_input'
require 'active_interaction/inputs/date_input'
require 'active_interaction/inputs/date_time_input'
require 'active_interaction/inputs/file_input'
require 'active_interaction/inputs/float_input'
require 'active_interaction/inputs/hash_input'
require 'active_interaction/inputs/integer_input'
require 'active_interaction/inputs/model_input'
require 'active_interaction/inputs/string_input'
require 'active_interaction/inputs/symbol_input'
require 'active_interaction/inputs/time_input'
require 'active_interaction/validation'
require 'active_interaction/base'

I18n.backend.load_translations(
  Dir.glob(File.join(%w(lib active_interaction locale *.yml)))
)

# @since 0.1.0
module ActiveInteraction end
