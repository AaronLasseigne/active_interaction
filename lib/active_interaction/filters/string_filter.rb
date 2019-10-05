# frozen_string_literal: true

module ActiveInteraction
  class Base
    # @!method self.string(*attributes, options = {})
    #   Creates accessors for the attributes and ensures that values passed to
    #     the attributes are Strings.
    #
    #   @!macro filter_method_params
    #   @option options [Boolean] :strip (true) strip leading and trailing
    #     whitespace
    #
    #   @example
    #     string :first_name
    #   @example
    #     string :first_name, strip: false
  end

  # @private
  class StringFilter < Filter
    register :string

    def cast(value, _interaction)
      if value.respond_to?(:to_str)
        value = value.to_str
        strip? ? value.strip : value
      else
        super
      end
    end

    private

    # @return [Boolean]
    def strip?
      options.fetch(:strip, true)
    end
  end
end
