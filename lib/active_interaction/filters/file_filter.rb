module ActiveInteraction
  class Base
    # Confirms that any values passed to the provided attributes are Files.
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
