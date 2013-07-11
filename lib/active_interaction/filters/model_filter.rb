module ActiveInteraction
  class Base
    # Creates accessors for the attributes and ensures that values passed to
    #   the attributes are the correct class.
    #
    # @macro attribute_method_params
    # @option options [Class, String, Symbol] :class (use the attribute name) Class name used to ensure the value.
    #
    # @example Ensures that the class is `Account`
    #   model :account
    #
    # @example Ensures that the class is `User`
    #   model :account, class: User
    #
    # @method self.model(*attributes, options = {})
  end

  # @private
  class ModelFilter < Filter
    def self.prepare(key, value, options = {}, &block)
      key_class = constantize(options.fetch(:class, key))

      case value
        when key_class
          value
        else
          super
      end
    end

    def self.constantize(constant_name)
      if constant_name.is_a?(Symbol) || constant_name.is_a?(String)
        constant_name.to_s.classify.constantize
      else
        constant_name
      end
    end
    private_class_method :constantize
  end
end
