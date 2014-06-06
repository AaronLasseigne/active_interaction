# coding: utf-8

module ActiveInteraction
  class Base
    # @!method self.rational(*attributes, options = {})
    #   Creates accessors for the attributes and ensures that values passed to
    #     the attributes are Rational.
    #
    #   @!macro filter_method_params
    #
    #   @example
    #     rational :grade
  end

  # @private
  class RationalFilter < AbstractFilter
    register :rational

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
