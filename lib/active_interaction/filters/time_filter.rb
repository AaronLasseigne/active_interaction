module ActiveInteraction
  # @private
  class TimeFilter < Filter
    def self.prepare(key, value, options = {}, &block)
      case value
        when Time
          value
        when String
          begin
            time.parse(value)
          rescue ArgumentError
            bad_value
          end
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
