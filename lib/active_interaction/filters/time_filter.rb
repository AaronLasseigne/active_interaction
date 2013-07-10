module ActiveInteraction
  # @private
  class TimeFilter < Filter
    def self.prepare(_, value, options = {})
      case value
        when Time
          value
        when Numeric
          time.at(value)
        else
          super
      end
    end

    def self.time
      if Time.respond_to?(:zone)
        Time.zone
      else
        Time
      end
    end
    private_class_method :time
  end
end
