# frozen_string_literal: true

require 'active_model'
require 'active_support/core_ext/hash/indifferent_access'
require 'action_controller'

# Manage application specific business logic.
#
# @author Aaron Lasseigne <aaron.lasseigne@gmail.com>
# @author Taylor Fausak <taylor@fausak.me>
module ActiveInteraction
end

require_relative 'active_interaction/version'
require_relative 'active_interaction/errors'

require_relative 'active_interaction/concerns/active_modelable'
require_relative 'active_interaction/concerns/active_recordable'
require_relative 'active_interaction/concerns/hashable'
require_relative 'active_interaction/concerns/missable'
require_relative 'active_interaction/concerns/runnable'

require_relative 'active_interaction/grouped_input'
require_relative 'active_interaction/input'
require_relative 'active_interaction/inputs'

require_relative 'active_interaction/modules/validation'

require_relative 'active_interaction/filter_column'
require_relative 'active_interaction/filter'
require_relative 'active_interaction/filters/interface_filter'
require_relative 'active_interaction/filters/abstract_date_time_filter'
require_relative 'active_interaction/filters/abstract_numeric_filter'
require_relative 'active_interaction/filters/array_filter'
require_relative 'active_interaction/filters/boolean_filter'
require_relative 'active_interaction/filters/date_filter'
require_relative 'active_interaction/filters/date_time_filter'
require_relative 'active_interaction/filters/decimal_filter'
require_relative 'active_interaction/filters/file_filter'
require_relative 'active_interaction/filters/float_filter'
require_relative 'active_interaction/filters/hash_filter'
require_relative 'active_interaction/filters/integer_filter'
require_relative 'active_interaction/filters/object_filter'
require_relative 'active_interaction/filters/record_filter'
require_relative 'active_interaction/filters/string_filter'
require_relative 'active_interaction/filters/symbol_filter'
require_relative 'active_interaction/filters/time_filter'

require_relative 'active_interaction/base'

I18n.load_path.unshift(
  *Dir.glob(
    File.expand_path(
      File.join(%w[active_interaction locale *.yml]), File.dirname(__FILE__)
    )
  )
)
