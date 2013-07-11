module ActiveInteraction
  # @private
  class BooleanFilter < Filter
    def self.prepare(key, value, options = {}, &block)
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
