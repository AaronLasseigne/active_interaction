module ActiveInteraction
  class FileInput < Input
    # @param value [Object]
    #
    # @return [File]
    #
    # @raise (see Input#cast)
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
