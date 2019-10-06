# frozen_string_literal: true

module ActiveInteraction
  class Base
    # @!method self.time(*attributes, options = {})
    #   Creates accessors for the attributes and ensures that values passed to
    #     the attributes are Times. Numeric values are processed using `at`.
    #     Strings are processed using `parse` unless the format option is
    #     given, in which case they will be processed with `strptime`. If
    #     `Time.zone` is available it will be used so that the values are time
    #     zone aware.
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

    alias _klass klass
    private :_klass # rubocop:disable Style/AccessModifierDeclarations

    def initialize(name, options = {}, &block)
      if options.key?(:format) && klass != Time
        raise InvalidFilterError, 'format option unsupported with time zones'
      end

      super
    end

    def cast(value, _interaction)
      value = value.to_int if value.respond_to?(:to_int)

      if value.is_a?(Numeric)
        klass.at(value)
      else
        super
      end
    end

    def database_column_type
      :datetime
    end

    private

    def klass
      if Time.respond_to?(:zone) && !Time.zone.nil?
        Time.zone
      else
        super
      end
    end

    def klasses
      [_klass, klass.at(0).class]
    end
  end
end
