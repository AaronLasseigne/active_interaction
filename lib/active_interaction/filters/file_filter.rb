module ActiveInteraction
  # @private
  class FileFilter < Filter
    def self.prepare(_, value, _ = {})
      case value
        when File
          value
        else
          super
      end
    end
  end
end
