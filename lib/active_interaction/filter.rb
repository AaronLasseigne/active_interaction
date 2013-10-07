module ActiveInteraction
  # @!macro [new] attribute_method_params
  #   @param *attributes [Symbol] One or more attributes to create.
  #   @param options [Hash]
  #   @option options [Boolean] :allow_nil Allow a `nil` value.
  #   @option options [Object] :default Value to use if `nil` is given.

  # @private
  class Filter
    def self.factory(type)
      ActiveInteraction.const_get("#{type.to_s.camelize}Filter")
    rescue NameError
      raise InvalidFilter
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
  end
end
