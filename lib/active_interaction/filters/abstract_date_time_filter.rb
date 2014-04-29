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

    def cast(value)
      case value
      when *klasses
        value
      when String
        convert(value)
      when Array
        convert(stringify(value))
      else
        super
      end
    end

    def database_column_type
      self.class.slug
    end

    private

    def convert(value)
      if format?
        klass.strptime(value, format)
      else
        klass.parse(value) ||
          (fail ArgumentError, "no time information in #{value.inspect}")
      end
    rescue ArgumentError
      _cast(value)
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

    def stringify(value)
      "#{value[0, 3].join('-')} #{value[3, 3].join(':')}".strip
    end
  end
end
