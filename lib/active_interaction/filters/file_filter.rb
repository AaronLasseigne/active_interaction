module ActiveInteraction
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
