# coding: utf-8

module ActiveInteraction
  class Base
    # Creates accessors for the attributes and ensures that values passed to
    #   the attributes are Files or Tempfiles. It will also extract a file from
    #   any object with a `tempfile` method. This is useful when passing in
    #   Rails params that include a file upload.
    #
    # @macro filter_method_params
    #
    # @example
    #   file :image
    #
    # @since 0.1.0
    #
    # @method self.file(*attributes, options = {})
  end

  # @private
  class FileFilter < Filter
    def cast(value)
      value = extract_file(value)

      case value
      when File, Tempfile
        value
      else
        super
      end
    end

    private

    def extract_file(value)
      if value.respond_to?(:tempfile)
        value.tempfile
      else
        value
      end
    end
  end
end
