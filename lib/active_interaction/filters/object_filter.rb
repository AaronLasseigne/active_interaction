# coding: utf-8

module ActiveInteraction
  class Base
    # @!method self.object(*attributes, options = {})
    #   Creates accessors for the attributes and ensures that values passed to
    #     the attributes are the correct class.
    #
    #   @!macro filter_method_params
    #   @option options [Class, String, Symbol] :class (use the attribute name)
    #     Class name used to ensure the value.
    #
    #   @example
    #     object :account
    #   @example
    #     object :account, class: User
  end

  # @private
  class ObjectFilter < Filter
    register :object

    def cast(value, reconstantize = true)
      @klass ||= klass

      if matches?(value)
        value
      else
        return super(value) unless reconstantize

        @klass = klass
        cast(value, false)
      end
    end

    private

    # @return [Class]
    #
    # @raise [InvalidClassError]
    def klass
      klass_name = options.fetch(:class, name).to_s.camelize
      Object.const_get(klass_name)
    rescue NameError
      raise InvalidClassError, klass_name.inspect
    end

    # @param value [Object]
    #
    # @return [Boolean]
    def matches?(value)
      @klass === value || # rubocop:disable CaseEquality
        value.is_a?(@klass)
    end
  end
end
