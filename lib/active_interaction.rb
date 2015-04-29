# coding: utf-8

require 'active_model'

# Manage application specific business logic.
#
# @author Aaron Lasseigne <aaron.lasseigne@gmail.com>
# @author Taylor Fausak <taylor@fausak.me>
#
# @since 1.0.0
#
# @version 1.5.1
module ActiveInteraction
  DEPRECATOR =
    if ::ActiveSupport::Deprecation.respond_to?(:new)
      ::ActiveSupport::Deprecation.new('2', 'ActiveInteraction')
    end
  private_constant :DEPRECATOR

  def self.deprecate(klass, method, message = nil)
    options = { method => message }
    options.merge(deprecator: DEPRECATOR) if DEPRECATOR
    klass.deprecate(options)
  end
end

require 'active_interaction/version'
require 'active_interaction/errors'

require 'active_interaction/concerns/active_modelable'
require 'active_interaction/concerns/active_recordable'
require 'active_interaction/concerns/hashable'
require 'active_interaction/concerns/missable'
require 'active_interaction/concerns/transactable'
require 'active_interaction/concerns/runnable'

require 'active_interaction/grouped_input'

require 'active_interaction/modules/input_processor'
require 'active_interaction/modules/validation'

require 'active_interaction/filter_column'
require 'active_interaction/filter'
require 'active_interaction/filters/abstract_filter'
require 'active_interaction/filters/abstract_date_time_filter'
require 'active_interaction/filters/abstract_numeric_filter'
require 'active_interaction/filters/array_filter'
require 'active_interaction/filters/boolean_filter'
require 'active_interaction/filters/date_filter'
require 'active_interaction/filters/date_time_filter'
require 'active_interaction/filters/decimal_filter'
require 'active_interaction/filters/file_filter'
require 'active_interaction/filters/float_filter'
require 'active_interaction/filters/hash_filter'
require 'active_interaction/filters/integer_filter'
require 'active_interaction/filters/interface_filter'
require 'active_interaction/filters/model_filter'
require 'active_interaction/filters/string_filter'
require 'active_interaction/filters/symbol_filter'
require 'active_interaction/filters/time_filter'

require 'active_interaction/base'

require 'active_interaction/backports'

I18n.load_path.unshift(*Dir[File.expand_path(
  File.join(%w[active_interaction locale *.yml]), File.dirname(__FILE__))])
