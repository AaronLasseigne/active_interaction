module ActiveInteraction
  # @private
  class DateFilter < Filter
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
        else
          super
      end
    end
  end
end
