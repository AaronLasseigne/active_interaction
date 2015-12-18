# coding: utf-8
# frozen_string_literal: true

module ActiveInteraction
  # @abstract
  #
  # Common logic for filters that handle numeric objects.
  #
  # @private
  class AbstractNumericFilter < AbstractFilter
    alias_method :_cast, :cast
    private :_cast

    def cast(value)
      case value
      when klass
        value
      when Numeric, String
        convert(value)
      else
        super
      end
    end

    def database_column_type
      self.class.slug
    end

    private

    def convert(value)
      Kernel.public_send(klass.name, value)
    rescue ArgumentError
      _cast(value)
    end
  end
end
