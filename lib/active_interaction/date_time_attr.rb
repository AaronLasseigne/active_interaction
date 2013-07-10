module ActiveInteraction
  # @private
  module DateTimeAttr
    extend Attr

    def self.prepare(_, value, options = {})
      case value
        when DateTime
          value
        when String
          begin
            DateTime.parse(value)
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
