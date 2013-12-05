module ActiveInteraction
  class Base
    # Creates accessors for the attributes and ensures that values passed to
    #   the attributes are Hashes.
    #
    # @macro filter_method_params
    # @param block [Proc] filter methods to apply for select keys
    # @option options [Boolean] :strip (true) strip unknown keys
    #
    # @example
    #   hash :order
    #
    # @example A Hash where certain keys also have their values ensured.
    #   hash :order do
    #     model :account
    #     model :item
    #     integer :quantity
    #     boolean :delivered
    #   end
    #
    # @since 0.1.0
    #
    # @method self.hash(*attributes, options = {}, &block)
  end

  # @private
  class HashFilter < Filter
    include MethodMissing

    def cast(value)
      case value
      when Hash
        value = value.symbolize_keys
        filters.each_with_object(strip? ? {} : value) do |filter, h|
          k = filter.name
          h[k] = filter.clean(value[k])
        end
      else
        super
      end
    end

    def default
      if options[:default].is_a?(Hash) && !options[:default].empty?
        fail InvalidDefaultError, "#{name}: #{options[:default].inspect}"
      end

      super
    end

    def method_missing(*args, &block)
      super(*args) do |klass, names, options|
        fail InvalidFilterError, 'missing attribute name' if names.empty?

        names.each do |name|
          filters.add(klass.new(name, options, &block))
        end
      end
    end

    private

    def strip?
      options.fetch(:strip, true)
    end
  end
end
