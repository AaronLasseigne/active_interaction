module ActiveInteraction
  class FileFilter < Filter
    # @param value [Object]
    #
    # @return [File]
    #
    # @raise (see Filter#cast)
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
