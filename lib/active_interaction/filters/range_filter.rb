# coding: utf-8

module ActiveInteraction
  class Base
    # @!method self.range(*attributes, options = {})
    #   Creates accessors for the attributes and ensures that values passed to
    #     the attributes are Ranges.
    #
    #   @!macro filter_method_params
    #
    #   @example
    #     range :bounds
  end

  # @private
  class RangeFilter < AbstractFilter
    register :range

    def cast(value)
      case value
      when klass
        value
      else
        super
      end
    end
  end
end
