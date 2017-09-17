# frozen_string_literal: true

module ActiveInteraction
  class Base
    # @!method self.date(*attributes, options = {})
    #   Creates accessors for the attributes and ensures that values passed to
    #     the attributes are Dates. String values are processed using `parse`
    #     unless the format option is given, in which case they will be
    #     processed with `strptime`.
    #
    #   @!macro filter_method_params
    #   @option options [String] :format parse strings using this format string
    #
    #   @example
    #     date :birthday
    #   @example
    #     date :birthday, format: '%Y-%m-%d'
  end

  # @private
  class DateFilter < AbstractDateTimeFilter
    register :date
  end
end
