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
        value = value.transform_keys { |k| k.is_a?(Symbol) ? k.to_s : k }

        filters.each_with_object(strip? ? {} : value) do |(name, filter), h|
          name = name.to_s if name.is_a?(Symbol)
          h[name] = filter.clean(value[name])
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
  end
end
