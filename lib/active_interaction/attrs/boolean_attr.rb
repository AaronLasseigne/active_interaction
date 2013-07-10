module ActiveInteraction
  # @private
  class BooleanAttr < Attr
    def self.prepare(_, value, options = {})
      case value
        when TrueClass, FalseClass
          value
        when '0'
          false
        when '1'
          true
        else
          super
      end
    end
  end
end
