# frozen_string_literal: true

module ActiveInteraction
  # @abstract
  #
  # Common logic for filters that handle numeric objects.
  #
  # @private
  class AbstractNumericFilter < Filter
    def database_column_type
      self.class.slug
    end

    private

    def matches?(value)
      value.is_a?(klass)
    rescue NoMethodError # BasicObject
      false
    end

    def convert(value)
      if value.is_a?(Numeric)
        [safe_converter(value), nil]
      elsif value.respond_to?(:to_int)
        [safe_converter(value.to_int), nil]
      elsif value.respond_to?(:to_str)
        value = value.to_str
        if value.blank?
          send(__method__, nil)
        else
          [safe_converter(value), nil]
        end
      else
        super
      end
    rescue NoMethodError # BasicObject
      super
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
