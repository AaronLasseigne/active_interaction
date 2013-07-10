module ActiveInteraction
  # @private
  class DateTimeAttr < Attr
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
        else
          super
      end
    end
  end
end
