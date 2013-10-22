module ActiveInteraction
  class Base
    # Creates accessors for the attributes and ensures that values passed to
    #   the attributes are DateTimes. String values are processed using `parse`
    #   unless the format option is given, in which case they will be processed
    #   with `strptime`.
    #
    # @macro attribute_method_params
    # @option options [String] :format Parse strings using this format string.
    #
    # @example
    #   date_time :start_date
    #
    # @example
    #   date_time :start_date, format: '%Y-%m-%dT%H:%M:%S'
    #
    # @method self.date_time(*attributes, options = {})
  end

  # @private
  class DateTimeCaster < Caster
    def self.prepare(filter, value)
      case value
        when DateTime
          value
        when String
          begin
            if filter.options.has_key?(:format)
              DateTime.strptime(value, filter.options[:format])
            else
              DateTime.parse(value)
            end
          rescue ArgumentError
            super
          end
        else
          super
      end
    end
  end
end
