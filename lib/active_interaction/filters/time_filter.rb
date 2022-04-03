# frozen_string_literal: true

module ActiveInteraction
  class Base # rubocop:disable Lint/EmptyClass
    # @!method self.time(*attributes, options = {})
    #   Creates accessors for the attributes and ensures that values passed to
    #     the attributes are Times. Numeric values are processed using `at`.
    #     Strings are processed using `parse` unless the format option is
    #     given, in which case they will be processed with `strptime`. Blank
    #     strings are treated as a `nil` value. If `Time.zone` is available it
    #     will be used so that the values are time zone aware.
    #
    #   @!macro filter_method_params
    #   @option options [String] :format parse strings using this format string
    #
    #   @example
    #     time :start_date
    #   @example
    #     time :start_date, format: '%Y-%m-%dT%H:%M:%S%Z'
  end

  # @private
  class TimeFilter < AbstractDateTimeFilter
    register :time

    def initialize(name, options = {}, &block)
      raise InvalidFilterError, 'format option unsupported with time zones' if options.key?(:format) && time_with_zone?

      super
    end

    def database_column_type
      :datetime
    end

    private

    def time_with_zone?
      Time.respond_to?(:zone) && !Time.zone.nil?
    end

    def klass
      if time_with_zone?
        Time.zone
      else
        super
      end
    end

    def klasses
      if time_with_zone?
        [Time.zone.at(0).class, Time]
      else
        super
      end
    end

    def convert(value)
      value = value.to_int if value.respond_to?(:to_int)

      if value.is_a?(Numeric)
        klass.at(value)
      else
        super
      end
    rescue NoMethodError # BasicObject
      super
    end
  end
end
