module ActiveInteraction
  class Base
    # Creates accessors for the attributes and ensures that values passed to
    #   the attributes are Dates. String values are processed using `parse`
    #   unless the format option is given, in which case they will be processed
    #   with `strptime`.
    #
    # @macro filter_method_params
    # @option options [String] :format parse strings using this format string
    #
    # @example
    #   date :birthday
    #
    # @example
    #   date :birthday, format: '%Y-%m-%d'
    #
    # @since 0.1.0
    #
    # @method self.date(*attributes, options = {})
  end

  # @private
  class DateFilter < AbstractDateTimeFilter
    private

    def klass
      Date
    end
  end
end
