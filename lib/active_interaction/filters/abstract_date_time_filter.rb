# coding: utf-8

module ActiveInteraction
  # @abstract
  #
  # Common logic for filters that handle `Date`, `DateTime`, and `Time`
  #   objects.
  #
  # @private
  class AbstractDateTimeFilter < AbstractFilter
    alias_method :_cast, :cast
    private :_cast

    def cast(value, interaction)
      case value
      when String
        convert(value, interaction)
      when GroupedInput
        convert(stringify(value), interaction)
      when *klasses
        value
      else
        super
      end
    end

    def database_column_type
      self.class.slug
    end

    private

    def convert(value, interaction)
      if format?
        klass.strptime(value, format)
      else
        klass.parse(value) ||
          (fail ArgumentError, "no time information in #{value.inspect}")
      end
    rescue ArgumentError
      _cast(value, interaction)
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
