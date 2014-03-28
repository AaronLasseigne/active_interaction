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
      else
        super
      end
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

    def extract(raw_inputs)
      case raw_inputs
      when Hash
        raw_inputs[name] || extract_rails_params(raw_inputs)
      else
        raw_inputs
      end
    end

    def extract_rails_params(inputs)
      if inputs.has_key?(:"#{name}(1i)") && inputs.has_key?(:"#{name}(2i)") && inputs.has_key?(:"#{name}(3i)")
        year  = inputs[:"#{name}(1i)"].to_i
        month = inputs[:"#{name}(2i)"].to_i
        day   = inputs[:"#{name}(3i)"].to_i
        Date.new(year, month, day)
      end
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
  end
end
