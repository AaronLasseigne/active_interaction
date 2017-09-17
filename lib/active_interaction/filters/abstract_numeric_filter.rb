# frozen_string_literal: true

module ActiveInteraction
  # @abstract
  #
  # Common logic for filters that handle numeric objects.
  #
  # @private
  class AbstractNumericFilter < AbstractFilter
    alias _cast cast
    private :_cast

    def cast(value, context)
      if value.is_a?(klass)
        value
      elsif value.is_a?(Numeric)
        convert(value, context)
      elsif value.respond_to?(:to_int)
        send(__method__, value.to_int, context)
      elsif value.respond_to?(:to_str)
        value = value.to_str
        value.blank? ? send(__method__, nil, context) : convert(value, context)
      else
        super
      end
    end

    def database_column_type
      self.class.slug
    end

    private

    def convert(value, context)
      converter(value)
    rescue ArgumentError
      _cast(value, context)
    end

    def converter(value)
      Kernel.public_send(klass.name, value)
    end
  end
end
