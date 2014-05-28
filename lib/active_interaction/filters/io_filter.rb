# coding: utf-8

module ActiveInteraction
  class Base
    # @!method self.io(*attributes, options = {})
    #   Creates accessors for the attributes and ensures that values passed to
    #     the attributes are IOs.
    #
    #   @!macro filter_method_params
    #
    #   @example
    #     io :input_output
  end

  # @private
  class IOFilter < Filter
    register :io

    def cast(value)
      case value
      when IO
        value
      else
        super
      end
    end
  end
end
