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

    private

    def matches?(object)
      methods.all? { |method| object.respond_to?(method) }
    end

    def methods
      options.fetch(:methods, [])
    end
  end
end
