module ActiveInteraction
  # @private
  class IntegerFilter < Filter
    def self.prepare(_, value, options = {})
      case value
        when Integer
          value
        when String
          begin
            Integer(value)
          rescue ArgumentError
            bad_value
          end
        else
          super
      end
    end
  end
end
