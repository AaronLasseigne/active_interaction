module ActiveInteraction
  class Base
    # Creates accessors for the attributes and ensures that values passed to
    #   the attributes are DateTimes. String values are processed using
    #   `parse`.
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
