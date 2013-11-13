module ActiveInteraction
  class FileFilter < Filter
    # @param value [Object]
    #
    # @return [File]
    #
    # @raise (see Filter#cast)
    def cast(value)
      case value
      when File
        value
      else
        super
      end
    end
  end
end
