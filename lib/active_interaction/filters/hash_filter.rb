module ActiveInteraction
  class Base
    # Creates accessors for the attributes and ensures that values passed to
    #   the attributes are Hashes.
    #
    # @macro attribute_method_params
    # @param block [Proc] filter methods to apply for select keys
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
    # @method self.hash(*attributes, options = {}, &block)
  end

  # @private
  class HashFilter < Filter
    include MethodMissing

    def cast(value)
      case value
      when Hash
        filters.reduce(strip? ? {} : value) do |h, f|
          k = f.name
          h[k] = f.clean(value[k])
          h
        end
      else
        super
      end
    end

    def default
      if options[:default].is_a?(Hash) && !options[:default].empty?
        raise InvalidDefault, "#{name}: #{options[:default].inspect}"
      end

      super
    end

    private

    def method_missing(*args, &block)
      super do |klass, names, options|
        raise InvalidFilter, 'no name' if names.empty?

        names.each do |name|
          filters.add(klass.new(name, options, &block))
        end
      end
    end

    def strip?
      options.fetch(:strip, true)
    end
  end
end
