# coding: utf-8

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
      when @klass
        value
      when Numeric, String
        convert(value)
      else
        super
      end
    end

    private

    def convert(value)
      Kernel.public_send(@klass.name, value)
    rescue ArgumentError
      _cast(value)
    end
  end
end
