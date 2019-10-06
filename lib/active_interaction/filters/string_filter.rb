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

    private

    def strip?
      options.fetch(:strip, true)
    end

    def matches?(value)
      value.is_a?(String)
    end

    def adjust_output(value, _context)
      strip? ? value.strip : value
    end

    def convert(value)
      if value.respond_to?(:to_str)
        value.to_str
      else
        value
      end
    end
  end
end
