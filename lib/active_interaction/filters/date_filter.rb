module ActiveInteraction
  # @private
  class DateFilter < Filter
    def self.prepare(key, value, options = {}, &block)
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
