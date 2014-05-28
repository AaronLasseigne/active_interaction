# coding: utf-8

module ActiveInteraction
  class Base
    # @!method self.enumerator(*attributes, options = {})
    #   Creates accessors for the attributes and ensures that values passed to
    #     the attributes are Enumerators.
    #
    #   @!macro filter_method_params
    #
    #   @example
    #     enumerator :things
  end

  # @private
  class EnumeratorFilter < AbstractFilter
    register :enumerator

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
