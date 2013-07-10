module ActiveInteraction
  # @private
  class Filter
    def self.factory(type)
      klass = "#{type.to_s.camelize}Filter"

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
