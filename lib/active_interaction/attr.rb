module ActiveInteraction
  # @private
  class Attr
    def self.factory(attr_type)
      klass = "#{attr_type.to_s.camelize}Attr"

      raise NoMethodError unless ActiveInteraction.const_defined?(klass)

      ActiveInteraction.const_get(klass)
    end

    def self.prepare(_, value, options = {})
      case value
        when NilClass
          return_nil(options[:allow_nil])
        else
          bad_value
        end
    end

    def self.return_nil(allow_nil)
      if allow_nil
        nil
      else
        raise MissingValue
      end
    end
    private_class_method :return_nil

    def self.bad_value
      raise InvalidValue
    end
    private_class_method :bad_value
  end
end
