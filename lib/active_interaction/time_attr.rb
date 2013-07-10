module ActiveInteraction
  # @private
  class TimeAttr < Attr
    def self.prepare(_, value, options = {})
      case value
        when Time
          value
        when Numeric
          Time.at(value)
        when NilClass
          return_nil(options[:allow_nil])
        else
          bad_value
      end
    end
  end
end
