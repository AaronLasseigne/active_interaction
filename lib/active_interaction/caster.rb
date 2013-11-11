module ActiveInteraction
  # @!macro [new] attribute_method_params
  #   @param *attributes [Symbol] One or more attributes to create.
  #   @param options [Hash]
  #   @option options [Boolean] :allow_nil Allow a `nil` value.
  #   @option options [Object] :default Value to use if `nil` is given.

  # @private
  class Caster
    def self.cast(filter, value)
      factory(filter.type).prepare(filter, value)
    end

    def self.factory(type)
      ActiveInteraction.const_get("#{type.to_s.camelize}Caster")
    end
    private_class_method :factory

    def self.prepare(filter, value)
      case value
        when NilClass
          if filter.options[:allow_nil]
            nil
          elsif filter.options.has_key?(:default)
            # REVIEW: This value isn't actually used anywhere. It is required
            #   to make the validator (Validation.validate) happy.
            filter.options[:default]
          else
            raise MissingValue
          end
        else
          raise InvalidValue
      end
    end
  end
end
