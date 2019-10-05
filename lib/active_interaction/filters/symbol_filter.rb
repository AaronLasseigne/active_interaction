# frozen_string_literal: true

module ActiveInteraction
  class Base
    # @!method self.symbol(*attributes, options = {})
    #   Creates accessors for the attributes and ensures that values passed to
    #     the attributes are Symbols. Strings will be converted to Symbols.
    #
    #   @!macro filter_method_params
    #
    #   @example
    #     symbol :condiment
  end

  # @private
  class SymbolFilter < Filter
    register :symbol

    def cast(value, _interaction)
      if value.respond_to?(:to_sym)
        value.to_sym
      else
        super
      end
    end
  end
end
