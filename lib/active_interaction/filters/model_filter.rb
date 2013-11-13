module ActiveInteraction
  class Base
    # Creates accessors for the attributes and ensures that values passed to
    #   the attributes are the correct class.
    #
    # @macro attribute_method_params
    # @option options [Class, String, Symbol] :class (use the attribute name)
    #   Class name used to ensure the value.
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
    def cast(value)
      case value
      when klass
        value
      else
        super
      end
    end

    private

    def klass
      name = options.fetch(:class, @name).to_s.classify
      name.constantize
    rescue NameError
      raise InvalidClass, name.inspect
    end
  end
end
