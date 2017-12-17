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

    private

    def klass
      klass_name = options.fetch(:class, name).to_s.camelize
      Object.const_get(klass_name)
    rescue NameError
      raise InvalidNameError, "class #{klass_name.inspect} does not exist"
    end

    def matches?(value)
      value.class <= klass
    rescue NoMethodError
      false
    end

    def convert(value)
      finder = options.fetch(:finder, :find)
      find(klass, value, finder)
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
