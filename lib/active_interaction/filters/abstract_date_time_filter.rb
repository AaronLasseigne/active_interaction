# frozen_string_literal: true

module ActiveInteraction
  # @abstract
  #
  # Common logic for filters that handle `Date`, `DateTime`, and `Time`
  #   objects.
  #
  # @private
  class AbstractDateTimeFilter < AbstractFilter
    alias _cast cast
    private :_cast # rubocop:disable Style/AccessModifierDeclarations

    def cast(value, context)
      if value.respond_to?(:to_str)
        convert(value.to_str, context)
      elsif value.is_a?(GroupedInput)
        convert(stringify(value), context)
      elsif klasses.include?(value.class)
        value
      else
        super
      end
    end

    def database_column_type
      self.class.slug
    end

    private

    def convert(value, context)
      if format?
        klass.strptime(value, format)
      else
        klass.parse(value) ||
          (raise ArgumentError, "no time information in #{value.inspect}")
      end
    rescue ArgumentError
      _cast(value, context)
    end

    # @return [String]
    def format
      options.fetch(:format)
    end

    # @return [Boolean]
    def format?
      options.key?(:format)
    end

    # @return [Array<Class>]
    def klasses
      [klass]
    end

    # @return [String]
    def stringify(value)
      date = %w[1 2 3].map { |key| value[key] }.join('-')
      time = %w[4 5 6].map { |key| value[key] }.join(':')

      "#{date} #{time}"
    end
  end
end
