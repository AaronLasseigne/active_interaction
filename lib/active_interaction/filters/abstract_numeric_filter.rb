# frozen_string_literal: true

module ActiveInteraction
  # @abstract
  #
  # Common logic for filters that handle numeric objects.
  #
  # @private
  class AbstractNumericFilter < AbstractFilter
    def database_column_type
      self.class.slug
    end

    private

    def matches?(value)
      value.is_a?(klass)
    end

    def convert(value)
      if value.is_a?(Numeric) || value.is_a?(String)
        safe_converter(value)
      elsif value.respond_to?(:to_int)
        safe_converter(value.to_int)
      else
        super
      end
    end

    def converter(value)
      Kernel.public_send(klass.name, value)
    end

    def safe_converter(value)
      converter(value)
    rescue ArgumentError
      value
    end
  end
end
