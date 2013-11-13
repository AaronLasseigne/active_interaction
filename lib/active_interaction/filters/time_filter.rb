module ActiveInteraction
  class TimeFilter < Filter
    # @param value [Object]
    #
    # @return [Time]
    #
    # @raise (see Filter#cast)
    def cast(value)
      case value
      when klass
        value
      when Numeric
        time.at(value)
      when String
        begin
          if has_format?
            klass.strptime(value, format)
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

    private

    def format
      options.fetch(:format)
    end

    def has_format?
      options.has_key?(:format)
    end

    def klass
      time.at(0).class
    end

    def time
      if Time.respond_to?(:zone) && !Time.zone.nil?
        Time.zone
      else
        Time
      end
    end
  end
end
