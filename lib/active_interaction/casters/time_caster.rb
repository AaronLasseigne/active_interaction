module ActiveInteraction
  class Base
    # Creates accessors for the attributes and ensures that values passed to
    #   the attributes are Times. Numeric values are processed using `at`.
    #   Strings are processed using `parse` unless the format option is given,
    #   in which case they will be processed with `strptime`. If `Time.zone` is
    #   available it will be used so that the values are time zone aware.
    #
    # @macro attribute_method_params
    # @option options [String] :format Parse strings using this format string.
    #
    # @example
    #   time :start_date
    #
    # @example
    #   date_time :start_date, format: '%Y-%m-%dT%H:%M:%S'
    #
    # @method self.time(*attributes, options = {})
  end

  # @private
  class TimeCaster < Caster
    def self.prepare(filter, value)
      case value
        when Numeric
          time.at(value)
        when time_class
          value
        when String
          begin
            if filter.options.has_key?(:format)
              time_class.strptime(value, filter.options[:format])
            else
              time_class.parse(value)
            end
          rescue ArgumentError
            super
          end
        else
          super
      end
    end

    def self.time
      if Time.respond_to?(:zone) && !Time.zone.nil?
        Time.zone
      else
        Time
      end
    end
    private_class_method :time

    def self.time_class
      time.at(0).class
    end
    private_class_method :time_class
  end
end
