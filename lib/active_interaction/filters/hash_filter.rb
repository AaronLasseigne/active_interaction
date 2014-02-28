# coding: utf-8

module ActiveInteraction
  class Base
    # @!method self.hash(*attributes, options = {}, &block)
    #   Creates accessors for the attributes and ensures that values passed to
    #     the attributes are Hashes.
    #
    #   @!macro filter_method_params
    #   @param block [Proc] filter methods to apply for select keys
    #   @option options [Boolean] :strip (true) strip unknown keys
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
        value = value.symbolize_keys
        filters.each_with_object(strip? ? {} : value) do |(name, filter), h|
          h[name] = filter.clean(value[name])
        end
      else
        super
      end
    end

    def default
      # TODO: Don't repeat yourself! This same logic exists in Filter#default.
      value = options[:default]
      value = value.call if value.is_a?(Proc)
      if value.is_a?(Hash) && !value.empty?
        fail InvalidDefaultError, "#{name}: #{value.inspect}"
      end

      super
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

    # @return [Boolean]
    def strip?
      options.fetch(:strip, true)
    end
  end
end
