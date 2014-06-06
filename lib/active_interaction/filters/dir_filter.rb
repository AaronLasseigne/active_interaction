# coding: utf-8

module ActiveInteraction
  class Base
    # @!method self.dir(*attributes, options = {})
    #   Creates accessors for the attributes and ensures that values passed to
    #     the attributes are Dirs.
    #
    #   @!macro filter_method_params
    #
    #   @example
    #     dir :directory
  end

  # @private
  class DirFilter < AbstractFilter
    register :dir

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
