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

    def initialize(name, options = {}, &block)
      super

      # rubocop:disable Style/GuardClause
      if options.key?(:format) && !supports_strptime?
        error_invalid_format_argument
      end
      # rubocop:enable Style/GuardClause
    end

    def database_column_type
      :datetime
    end

    private

    def supports_strptime?
      !time_with_zone? || Time.zone.respond_to?(:strptime)
    end

    def time_with_zone?
      Time.respond_to?(:zone) && !Time.zone.nil?
    end

    def obj
      time_with_zone? ? Time.zone : Time
    end

    def klasses
      if time_with_zone?
        super + [Time.zone.class]
      else
        super
      end
    end

    def convert(value)
      value = value.to_int if value.respond_to?(:to_int)

      if value.is_a?(Numeric)
        obj.at(value)
      else
        super
      end
    rescue NoMethodError
      false
    end

    def error_invalid_format_argument
      fixable = lambda do
        Kernel.const_defined?('::ActiveSupport') &&
        Kernel.const_get('::ActiveSupport').version < Gem::Version.new('5.0.0')
      end

      issue_desc = <<-MSG.strip
        The format option is not allowed because `Time.zone` does not support `strptime`.
      MSG
      fix_desc = <<-MSG.strip
        Upgrading ActiveSupport (or Rails) to at least 5.0.0 will add support for `strptime`.
      MSG

      raise InvalidFilterError, ErrorMessage.new(
        issue: { desc: issue_desc, code: source_str, lines: [0] },
        fix: { if: fixable.call, desc: fix_desc }
      )
    end
  end
end
