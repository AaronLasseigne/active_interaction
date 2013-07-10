module ActiveInteraction
  # @private
  class FloatAttr < Attr
    def self.prepare(_, value, options = {})
      case value
        when Float
          value
        when String
          begin
            Float(value)
          rescue ArgumentError
            bad_value
          end
        else
          super
      end
    end
  end
end
