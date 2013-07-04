module ActiveInteraction
  module StringAttr
    extend Attr

    def self.prepare(value, options = {})
      case value
        when String
          value
        when NilClass
          return_nil(options[:allow_nil])
        else
          bad_value
      end
    end
  end
end
