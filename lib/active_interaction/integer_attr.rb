module ActiveInteraction
  # @private
  class IntegerAttr < Attr
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
        when NilClass
          return_nil(options[:allow_nil])
        else
          bad_value
      end
    end
  end
end
