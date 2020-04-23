# frozen_string_literal: true

module ActiveInteraction
  # @abstract
  #
  # Common logic for filters that handle `Date`, `DateTime`, and `Time`
  #   objects.
  #
  # @private
  class AbstractDateTimeFilter < Filter
    def database_column_type
      self.class.slug
    end

    private

    def klasses
      [klass]
    end

    def matches?(value)
      klasses.any? { |klass| value.is_a?(klass) }
    rescue NoMethodError # BasicObject
      false
    end

    def convert(value)
      if value.respond_to?(:to_str)
        value = value.to_str
        value.blank? ? send(__method__, nil) : convert_string(value)
      elsif value.is_a?(GroupedInput)
        convert_grouped_input(value)
      else
        super
      end
    rescue ArgumentError
      value
    rescue NoMethodError # BasicObject
      super
    end

    def convert_string(value)
      if format?
        klass.strptime(value, format)
      else
        klass.parse(value) ||
          (raise ArgumentError, "no time information in #{value.inspect}")
      end
    end

    def convert_grouped_input(value)
      date = %w[1 2 3].map { |key| value[key] }.join('-')
      time = %w[4 5 6].map { |key| value[key] }.join(':')

      convert_string("#{date} #{time}")
    end

    def format
      options.fetch(:format)
    end

    def format?
      options.key?(:format)
    end
  end
end
