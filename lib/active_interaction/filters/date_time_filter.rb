module ActiveInteraction
  class Base
    # Confirms that any values passed to the provided attributes are DateTimes.
    #   Strings are processed using `parse`.
    #
    # @macro attribute_method_params
    #
    # @example
    #   date_time :start_date
    #
    # @method self.date_time(*attributes, options = {})
  end

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
