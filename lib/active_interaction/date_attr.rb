module ActiveInteraction
  module DateAttr
    extend Attr

    def self.prepare(_, value, options = {})
      case value
        when Date
          value
        when NilClass
          return_nil(options[:allow_nil])
        else
          bad_value
      end
    end
  end
end
