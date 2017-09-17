# frozen_string_literal: true

module ActiveInteraction
  class Base
    # @!method self.interface(*attributes, options = {})
    #   Creates accessors for the attributes and ensures that values passed to
    #   the attributes implement an interface.
    #
    #   @!macro filter_method_params
    #   @option options [Array<String,Symbol>] :methods ([]) the methods that
    #     objects conforming to this interface should respond to
    #
    #   @example
    #     interface :anything
    #   @example
    #     interface :serializer,
    #       methods: %i[dump load]
  end

  # @private
  class InterfaceFilter < Filter
    register :interface

    def cast(value, _interaction)
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
