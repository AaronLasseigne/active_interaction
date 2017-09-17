# frozen_string_literal: true

module ActiveInteraction
  class Base
    # @!method self.date_time(*attributes, options = {})
    #   Creates accessors for the attributes and ensures that values passed to
    #     the attributes are DateTimes. String values are processed using
    #     `parse` unless the format option is given, in which case they will be
    #     processed with `strptime`.
    #
    #   @!macro filter_method_params
    #   @option options [String] :format parse strings using this format string
    #
    #   @example
    #     date_time :start_date
    #   @example
    #     date_time :start_date, format: '%Y-%m-%dT%H:%M:%SZ'
  end

  # @private
  class DateTimeFilter < AbstractDateTimeFilter
    register :date_time

    def database_column_type
      :datetime
    end
  end
end
