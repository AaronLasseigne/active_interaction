module ActiveInteraction
  # @private
  class StringFilter < Filter
    def self.prepare(key, value, options = {}, &block)
      case value
        when String
          value
        else
          super
      end
    end
  end
end
