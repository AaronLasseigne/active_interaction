module ActiveInteraction
  # @private
  class IntegerFilter < Filter
    def cast(value)
      case value
      when Numeric
        value.to_i
      when String
        begin
          Integer(value)
        rescue ArgumentError
          super
        end
      else
        super
      end
    end
  end
end
