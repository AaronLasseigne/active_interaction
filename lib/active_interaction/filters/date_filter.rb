module ActiveInteraction
  class Base
    # Creates accessors for the attributes and ensures that values passed to
    #   the attributes are Dates. String values are processed using `parse`
    #   unless the format option is given, in which case they will be processed
    #   with `strptime`.
    #
    # @macro attribute_method_params
    # @option options [String] :format Parse strings using this format string.
    #
    # @example
    #   date :birthday
    #
    # @example
    #   date :birthday, format: '%Y-%m-%d'
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
            if options.has_key?(:format)
              Date.strptime(value, options[:format])
            else
              Date.parse(value)
            end
          rescue ArgumentError
            bad_value
          end
        else
          super
      end
    end
  end
end
