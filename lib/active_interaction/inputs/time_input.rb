module ActiveInteraction
  class TimeInput < Input
    # @param value [Object]
    #
    # @return [Time]
    #
    # @raise (see Input#cast)
    def cast(value)
      case value
      when klass
        value
      when Numeric
        time.at(value)
      when String
        begin
          if @options.has_key?(:format)
            klass.strptime(value, @options[:format])
          else
            klass.parse(value)
          end
        rescue ArgumentError
          super
        end
      else
        super
      end
    end

    # @return [Class]
    def klass
      time.at(0).class
    end

    # @return [TimeWithZone]
    # @return [Time]
    def time
      if Time.respond_to?(:zone) && !Time.zone.nil?
        Time.zone
      else
        Time
      end
    end
  end
end
