module ActiveInteraction
  # @private
  class StringAttr < Attr
    def self.prepare(_, value, options = {})
      case value
        when String
          value
        else
          super
      end
    end
  end
end
