module ActiveInteraction
  # @private
  class IntegerFilter < Filter
    def self.prepare(key, value, options = {}, &block)
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
