module ActiveInteraction
  # @private
  class FloatFilter < Filter
    def cast(value)
      case value
      when Numeric
        value.to_f
      when String
        begin
          Float(value)
        rescue ArgumentError
          super
        end
      else
        super
      end
    end
  end
end
