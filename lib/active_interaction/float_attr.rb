module ActiveInteraction
  module FloatAttr
    extend Attr

    def self.prepare(_, value, options = {})
      case value
        when Float
          value
        when String
          begin
            Float(value)
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
