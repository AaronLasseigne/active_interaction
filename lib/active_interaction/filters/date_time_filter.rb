# coding: utf-8

module ActiveInteraction
  class Base
    # Creates accessors for the attributes and ensures that values passed to
    #   the attributes are DateTimes. String values are processed using `parse`
    #   unless the format option is given, in which case they will be processed
    #   with `strptime`.
    #
    # @macro filter_method_params
    # @option options [String] :format parse strings using this format string
    #
    # @example
    #   date :start_date
    #
    # @example
    #   date :start_date, format: '%Y-%m-%dT%H:%M:%S%:z'
    #
    # @since 0.1.0
    #
    # @method self.date_time(*attributes, options = {})
  end

  # @private
  class DateTimeFilter < AbstractDateTimeFilter
    private

    def klass
      DateTime
    end
  end
end
