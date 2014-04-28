# coding: utf-8

module ActiveInteraction
  class Base
    # @!method self.hash(*attributes, options = {}, &block)
    #   Creates accessors for the attributes and ensures that values passed to
    #     the attributes are Hashes.
    #
    #   @!macro filter_method_params
    #   @param block [Proc] filter methods to apply for select keys
    #   @option options [Boolean] :strip (true) strip unknown keys (Note: All
    #     keys are symbolized. Ruby does not GC symbols so this can cause
    #     memory bloat. Setting this option to `false` and passing in non-safe
    #     input (e.g. Rails `params`) opens your software to a denial of
    #     service attack.)
    #
    #   @example
    #     hash :order
    #   @example
    #     hash :order do
    #       model :item
    #       integer :quantity, default: 1
    #     end
  end

  # @private
  class HashFilter < Filter
    include Missable

    def cast(value)
      case value
      when Hash
        value = symbolize_the_string_keys(value)

        filters.each_with_object(strip? ? {} : value) do |(name, filter), h|
          name = name.to_s
          f(h, name, filter, value)
        end.symbolize_keys
      else
        super
      end
    end

    def method_missing(*args, &block)
      super(*args) do |klass, names, options|
        fail InvalidFilterError, 'missing attribute name' if names.empty?

        names.each do |name|
          filters[name] = klass.new(name, options, &block)
        end
      end
    end

    private

    def f(h, name, filter, value)
      h[name] = filter.clean(value[name])
    rescue InvalidValueError, MissingValueError
      raise InvalidNestedValueError.new(name, value[name])
    end

    def raw_default
      value = super

      if value.is_a?(Hash) && !value.empty?
        fail InvalidDefaultError, "#{name}: #{value.inspect}"
      end

      value
    end

    # @return [Boolean]
    def strip?
      options.fetch(:strip, true)
    end

    # Switch to `transform_keys` once we support only Rails 4.0.2+
    def symbolize_the_string_keys(hash)
      new_hash = {}
      hash.each_key do |key|
        new_key = key.is_a?(Symbol) ? key.to_s : key
        new_hash[new_key] = hash[key]
      end
      new_hash
    end
  end
end
