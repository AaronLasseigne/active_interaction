module ActiveInteraction
  # @private
  class DateAttr < Attr
    def self.prepare(_, value, options = {})
      case value
        when Date
          value
        when String
          begin
            Date.parse(value)
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
