module ActiveInteraction
  module Attr
    def self.factory(attr_type)
      klass = "#{attr_type.to_s.capitalize}Attr"

      raise NoMethodError unless ActiveInteraction.const_defined?(klass)

      ActiveInteraction.const_get(klass)
    end

    def return_nil(allow_nil)
      allow_nil ? nil : bad_value
    end
    private :return_nil

    def bad_value
      raise ArgumentError
    end
    private :bad_value
  end
end
