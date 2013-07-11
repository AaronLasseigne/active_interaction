module ActiveInteraction
  class Base
    # Confirms that any values passed to the provided attributes are Dates.
    #   Strings are processed using `parse`.
    #
    # @macro attribute_method_params
    #
    # @example
    #   date :birthday
    #
    # @method self.date(*attributes, options = {})
  end

  # @private
  class DateFilter < Filter
    def self.prepare(key, value, options = {}, &block)
      case value
        when Date
          value
        when String
          begin
            Date.parse(value)
          rescue ArgumentError
            bad_value
          end
        else
          super
      end
    end
  end
end
