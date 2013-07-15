module ActiveInteraction
  class Base
    # Creates accessors for the attributes and ensures that values passed to
    #   the attributes are Files or TempFiles. It will also extract a file from
    #   any object with a `tempfile` method. This is useful when passing in Rails
    #   params that include a file upload.
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
      value = extract_file(value)

      case value
        when File, Tempfile
          value
        else
          super
      end
    end

    def self.extract_file(value)
      if value.respond_to?(:tempfile)
        value.tempfile
      else
        value
      end
    end
    private_class_method :extract_file
  end
end
