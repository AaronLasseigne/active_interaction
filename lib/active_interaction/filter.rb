module ActiveInteraction
  # @!macro [new] attribute_method_params
  #   @param *attributes [Symbol] One or more attributes to create.
  #   @param options [Hash]
  #   @option options [Boolean] :allow_nil Allow a `nil` value.
  #   @option options [Object] :default Value to use if `nil` is given.

  # @private
  class Filter
    def self.factory(type)
      klass = "#{type.to_s.camelize}Filter"

      raise NoMethodError unless ActiveInteraction.const_defined?(klass)

      ActiveInteraction.const_get(klass)
    end

    def self.prepare(key, value, options = {}, &block)
      case value
        when NilClass
          if options[:allow_nil]
            nil
          elsif options.has_key?(:default)
            options[:default]
          else
            raise MissingValue
          end
        else
          raise InvalidValue
      end
    end

    def self.default(key, value, options = {}, &block)
      begin
        self.prepare(key, value, options, &block)
      rescue InvalidValue, InvalidNestedValue
        raise InvalidDefaultValue
      end
    end
  end
end
