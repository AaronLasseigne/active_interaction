module ActiveInteraction
  module BooleanAttr
    extend Attr

    def self.prepare(value, options = {})
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
