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

    def matches?(value)
      value.is_a?(String)
    rescue NoMethodError
      false
    end

    def adjust_output(value, _context)
      strip? ? value.strip : value
    end

    def strip?
      options.fetch(:strip, true)
    end

    def convert(value)
      if value.respond_to?(:to_str)
        value.to_str
      else
        value
      end
    rescue NoMethodError
      false
    end
  end
end
