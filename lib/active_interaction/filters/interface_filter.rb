# coding: utf-8

module ActiveInteraction
  class Base
    # @!method self.interface(*attributes, options = {})
    #   Creates accessors for the attributes and ensures that values passed to
    #   the attributes implement an interface.
    #
    #   @!macro filter_method_params
    #   @option options [Array<Symbol>] :methods ([]) the methods that make up
    #     this interface
    #
    #   @example
    #     interface :anything
    #   @example
    #     interface :lengthy,
    #       methods: [:length]
  end

  # @private
  class InterfaceFilter < Filter
    def cast(value)
      matches?(value) ? value : super
    end

    private

    # @param object [Object]
    #
    # @return [Boolean]
    def matches?(object)
      methods.all? { |method| object.respond_to?(method) }
    rescue NoMethodError
      false
    end

    # @return [Array<Symbol>]
    def methods
      options.fetch(:methods, [])
    end
  end
end
