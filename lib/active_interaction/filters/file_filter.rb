module ActiveInteraction
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
