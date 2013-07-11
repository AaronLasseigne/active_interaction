module ActiveInteraction
  class Base
    # Confirms that any values passed to the provided attributes are the correct Class.
    #
    # @macro attribute_method_params
    # @option options [Class, String, Symbol] :class (use the attribute name) Class name used to confirm the provided value.
    #
    # @example Confirms that the Class is `Account`
    #   model :account
    #
    # @example Confirms that the Class is `User`
    #   model :account, class: User
    #
    # @method self.model(*attributes, options = {})

    # Confirms that any values passed to the provided attributes are Strings.
    #
    # @macro attribute_method_params
    #
    # @example
    #   string :first_name
    #
    # @method self.string(*attributes, options = {})
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
