# coding: utf-8

module ActiveInteraction
  # @private
  class AbstractNumericFilter < AbstractFilter
    def cast(value)
      case value
      when klass
        value
      when Numeric, String
        begin
          send(klass.name, value)
        rescue ArgumentError
          super
        end
      else
        super
      end
    end
  end
end
