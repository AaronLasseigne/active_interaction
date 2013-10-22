require 'active_model'

require 'active_interaction/version'
require 'active_interaction/errors'
require 'active_interaction/overload_hash'
require 'active_interaction/filter'
require 'active_interaction/filter_with_block'
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
require 'active_interaction/filters/time_filter'
require 'active_interaction/filter_methods'
require 'active_interaction/caster'
require 'active_interaction/casters/array_caster'
require 'active_interaction/casters/boolean_caster'
require 'active_interaction/casters/date_caster'
require 'active_interaction/casters/date_time_caster'
require 'active_interaction/casters/file_caster'
require 'active_interaction/casters/float_caster'
require 'active_interaction/casters/hash_caster'
require 'active_interaction/casters/integer_caster'
require 'active_interaction/casters/model_caster'
require 'active_interaction/casters/string_caster'
require 'active_interaction/casters/time_caster'
require 'active_interaction/base'

I18n.backend.load_translations(
  Dir.glob(File.join(%w(lib active_interaction locale *.yml)))
)

# @since 0.1.0
module ActiveInteraction end
