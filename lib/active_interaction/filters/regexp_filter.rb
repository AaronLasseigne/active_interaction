# coding: utf-8

module ActiveInteraction
  class Base
    # @!method self.regexp(*attributes, options = {})
    #   Creates accessors for the attributes and ensures that values passed to
    #     the attributes are Regexps.
    #
    #   @!macro filter_method_params
    #
    #   @example
    #     regexp :pattern
  end

  # @private
  class RegexpFilter < AbstractFilter
    register :regexp

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
