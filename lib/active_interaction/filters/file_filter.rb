module ActiveInteraction
  class Base
    # Creates accessors for the attributes and ensures that values passed to
    #   the attributes are Files.
    #
    # @macro attribute_method_params
    #
    # @example
    #   file :image
    #
    # @method self.file(*attributes, options = {})
  end

  # @private
  class FileFilter < Filter
    def self.prepare(key, value, options = {}, &block)
      case value
        when File
          value
        else
          super
      end
    end
  end
end
