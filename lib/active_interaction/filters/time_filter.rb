module ActiveInteraction
  # @private
  class TimeFilter < Filter
    def self.prepare(_, value, options = {})
      case value
        when Time
          value
        when Numeric
          Time.at(value)
        else
          super
      end
    end
  end
end
