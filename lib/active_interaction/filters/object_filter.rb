# frozen_string_literal: true

module ActiveInteraction
  class Base
    # @!method self.object(*attributes, options = {})
    #   Creates accessors for the attributes and ensures that values passed to
    #     the attributes are the correct class.
    #
    #   @!macro filter_method_params
    #   @option options [Class, String, Symbol] :class (use the attribute name)
    #     Class name used to ensure the value.
    #   @option options [Proc, Symbol] :converter A symbol specifying the name
    #     of a class method of `:class` or a Proc that is called when a new
    #     value is assigned to the value object. The converter is passed the
    #     single value that is used in the assignment and is only called if the
    #     new value is not an instance of `:class`. The class method or proc
    #     are passed the value. Any error thrown inside the converter is trapped
    #     and the value provided is treated as invalid. Any returned value that
    #     is not the correct class will also be treated as invalid.
    #
    #   @example
    #     object :account
    #   @example
    #     object :account, class: User
  end

  # @private
  class ObjectFilter < Filter
    register :object

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def cast(value, context, reconstantize: true, convert: true)
      @klass ||= klass

      if matches?(value)
        value
      elsif reconstantize
        @klass = klass
        public_send(__method__, value, context,
          reconstantize: false,
          convert: convert
        )
      elsif !value.nil? && convert && (converter = options[:converter])
        value = convert(klass, value, converter)
        public_send(__method__, value, context,
          reconstantize: reconstantize,
          convert: false
        )
      else
        super(value, context)
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    private

    # @return [Class]
    #
    # @raise [InvalidClassError]
    def klass
      klass_name = options.fetch(:class, name).to_s.camelize
      Object.const_get(klass_name)
    rescue NameError
      raise InvalidClassError, "class #{klass_name.inspect} does not exist"
    end

    # @param value [Object]
    #
    # @return [Boolean]
    def matches?(value)
      @klass === value || # rubocop:disable Style/CaseEquality
        value.is_a?(@klass)
    end

    def convert(klass, value, converter) # rubocop:disable Metrics/MethodLength
      result =
        case converter
        when Proc
          converter.call(value)
        when Symbol
          klass.public_send(converter, value)
        else
          raise InvalidConverterError,
            "#{converter.inspect} is not a valid converter"
        end

      raise InvalidValueError if result.nil?

      result
    rescue StandardError => e
      raise e if e.is_a?(InvalidConverterError)

      raise InvalidValueError
    end
  end
end
