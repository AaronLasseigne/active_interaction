module ActiveInteraction
  # @private
  class DateTimeFilter < Filter
    def self.prepare(key, value, options = {}, &block)
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
