# frozen_string_literal: true

module ActiveInteraction
  class Base # rubocop:disable Lint/EmptyClass
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
    rescue NoMethodError # BasicObject
      false
    end

    def convert(value)
      if value.respond_to?(:to_sym)
        [value.to_sym, nil]
      else
        super
      end
    rescue NoMethodError # BasicObject
      super
    end
  end
end
