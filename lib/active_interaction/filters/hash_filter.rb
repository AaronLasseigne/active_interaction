# frozen_string_literal: true

module ActiveInteraction
  class Base
    # @!method self.hash(*attributes, options = {}, &block)
    #   Creates accessors for the attributes and ensures that values passed to
    #     the attributes are Hashes.
    #
    #   @!macro filter_method_params
    #   @param block [Proc] filter methods to apply for select keys
    #   @option options [Boolean] :strip (true) remove unknown keys
    #
    #   @example
    #     hash :order
    #   @example
    #     hash :order do
    #       object :item
    #       integer :quantity, default: 1
    #     end
  end

  # @private
  class HashFilter < Filter
    include Missable

    register :hash

    def cast(value, context)
      case value
      when Hash
        value = value.with_indifferent_access
        initial = strip? ? ActiveSupport::HashWithIndifferentAccess.new : value

        filters.each_with_object(initial) do |(name, filter), hash|
          clean_value(hash, name.to_s, filter, value, context)
        end
      else
        super
      end
    end

    # rubocop:disable Style/MissingRespondToMissing, Style/MethodMissingSuper
    def method_missing(*args, &block)
      super(*args) do |klass, names, options|
        raise InvalidFilterError, 'missing attribute name' if names.empty?

        names.each do |name|
          filters[name] = klass.new(name, options, &block)
        end
      end
    end
    # rubocop:enable Style/MissingRespondToMissing, Style/MethodMissingSuper

    private

    def clean_value(hash, name, filter, value, context)
      hash[name] = filter.clean(value[name], context)
    rescue InvalidValueError, MissingValueError
      raise InvalidNestedValueError.new(name, value[name])
    end

    def raw_default(*)
      value = super

      if value.is_a?(Hash) && !value.empty?
        raise InvalidDefaultError, "#{name}: #{value.inspect}"
      end

      value
    end

    # @return [Boolean]
    def strip?
      options.fetch(:strip, true)
    end
  end
end
