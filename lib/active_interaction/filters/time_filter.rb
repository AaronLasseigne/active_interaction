module ActiveInteraction
  class Base
    # Creates accessors for the attributes and ensures that values passed to
    #   the attributes are Times. Numeric values are processed using `at`.
    #   Strings are processed using `parse`. If `Time.zone` is available it will
    #   be used so that the values are time zone aware.
    #
    # @macro attribute_method_params
    #
    # @example
    #   time :start_date
    #
    # @method self.time(*attributes, options = {})
  end

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
