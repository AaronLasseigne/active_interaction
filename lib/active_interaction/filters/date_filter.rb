module ActiveInteraction
  class Base
    # Creates accessors for the attributes and ensures that values passed to
    #   the attributes are Dates. String values are processed using `parse`.
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
