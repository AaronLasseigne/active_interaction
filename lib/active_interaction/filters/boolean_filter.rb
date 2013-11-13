module ActiveInteraction
  # @private
  class BooleanFilter < Filter
    def cast(value)
      case value
      when FalseClass, '0'
        false
      when TrueClass, '1'
        true
      else
        super
      end
    end
  end
end
