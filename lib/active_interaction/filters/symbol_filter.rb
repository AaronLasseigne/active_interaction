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

    private

    def matches?(value)
      value.is_a?(Symbol)
    end

    def convert(value)
      if value.respond_to?(:to_sym)
        value.to_sym
      else
        super
      end
    end
  end
end
