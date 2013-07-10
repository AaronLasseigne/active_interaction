module ActiveInteraction
  # @private
  class FloatFilter < Filter
    def self.prepare(_, value, options = {})
      case value
        when Float
          value
        when Integer, String
          begin
            Float(value)
          rescue ArgumentError
            bad_value
          end
        else
          super
      end
    end
  end
end
