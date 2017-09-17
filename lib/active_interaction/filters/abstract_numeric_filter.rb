# frozen_string_literal: true

module ActiveInteraction
  # @abstract
  #
  # Common logic for filters that handle numeric objects.
  #
  # @private
  class AbstractNumericFilter < AbstractFilter
    alias _cast cast
    private :_cast # rubocop:disable Style/AccessModifierDeclarations

    def cast(value, context)
      case value
      when klass
        value
      when Numeric, String
        convert(value, context)
      else
        super
      end
    end

    def database_column_type
      self.class.slug
    end

    private

    def convert(value, context)
      Kernel.public_send(klass.name, value)
    rescue ArgumentError
      _cast(value, context)
    end
  end
end
