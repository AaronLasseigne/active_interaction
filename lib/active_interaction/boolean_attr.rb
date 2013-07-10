module ActiveInteraction
  # @private
  class BooleanAttr < Attr
    def self.prepare(_, value, options = {})
      case value
        when TrueClass, FalseClass
          value
        when '0'
          false
        when '1'
          true
        when NilClass
          return_nil(options[:allow_nil])
        else
          bad_value
      end
    end
  end
end
