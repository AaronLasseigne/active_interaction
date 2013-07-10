module ActiveInteraction
  # @private
  class StringFilter < Filter
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
