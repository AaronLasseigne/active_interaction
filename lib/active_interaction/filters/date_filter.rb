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
  class DateFilter < AbstractDateTimeFilter
    def self.prepare(key, value, options = {}, &block)
      super(key, value, options.merge(class: Date), &block)
    end
  end
end
