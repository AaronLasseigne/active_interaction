# coding: utf-8

module ActiveInteraction
  class Base
    # @!method self.model(*attributes, options = {})
    #   Creates accessors for the attributes and ensures that values passed to
    #     the attributes are the correct class.
    #
    #   @!macro filter_method_params
    #   @option options [Class, String, Symbol] :class (use the attribute name)
    #     Class name used to ensure the value.
    #
    #   @example
    #     model :account
    #   @example
    #     model :account, class: User
  end

  # @private
  class ModelFilter < Filter
    def initialize(*)
      super

      constantize
    end

    def cast(value)
      case value
      when @klass
        value
      else
        return super if value.class.name != @klass.name

        constantize
        cast(value)
      end
    end

    private

    # @return (see #klass)
    #
    # @raise (see #klass)
    def constantize
      @klass = klass
    end

    # @return [Class]
    #
    # @raise [InvalidClassError]
    def klass
      klass_name = options.fetch(:class, name).to_s.classify
      klass_name.constantize
    rescue NameError
      raise InvalidClassError, klass_name.inspect
    end
  end
end
