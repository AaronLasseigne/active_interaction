# frozen_string_literal: true

module ActiveInteraction
  class Base
    # @!method self.record(*attributes, options = {})
    #   Creates accessors for the attributes and ensures that values passed to
    #     the attributes are the correct class.
    #
    #   @!macro filter_method_params
    #   @option options [Class, String, Symbol] :class (use the attribute name)
    #     Class name used to ensure the value.
    #   @option options [Symbol] :finder A symbol specifying the name of a
    #     class method of `:class` that is called when a new value is assigned
    #     to the object. The finder is passed the single value that is used in
    #     the assignment and is only called if the new value is not an instance
    #     of `:class`. The class method is passed the value. Any error thrown
    #     inside the finder is trapped and the value provided is treated as
    #     invalid. Any returned value that is not the correct class will also
    #     be treated as invalid.
    #
    #   @example
    #     record :account
    #   @example
    #     record :account, class: User
  end

  # @private
  class RecordFilter < Filter
    register :record

    # rubocop:disable Metrics/MethodLength
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
      elsif !value.nil? && convert
        finder = options.fetch(:finder, :find)
        value = find(klass, value, finder)
        public_send(__method__, value, context,
          reconstantize: reconstantize,
          convert: false
        )
      else
        super(value, context)
      end
    end
    # rubocop:enable Metrics/MethodLength

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

    def find(klass, value, finder)
      result = klass.public_send(finder, value)

      raise InvalidValueError if result.nil?

      result
    rescue StandardError => e
      raise e if e.is_a?(InvalidConverterError)

      raise InvalidValueError
    end
  end
end
