# frozen_string_literal: true

module ActiveInteraction
  class Base # rubocop:disable Lint/EmptyClass
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

    def process(value, context)
      input = super

      return HashInput.new(value: input.value, error: input.error) if input.error
      return HashInput.new(value: default(context), error: input.error) if input.value.nil?

      value = strip? ? HashWithIndifferentAccess.new : input.value
      error = nil
      children = {}

      filters.each do |name, filter|
        filter.process(input.value[name], context).tap do |result|
          value[name] = result.value
          error ||= InvalidNestedValueError.new(name, input.value[name]) if result.error
          children[name.to_sym] = result
        end
      end

      HashInput.new(value: value, error: error, children: children)
    end

    private

    def matches?(value)
      value.is_a?(Hash)
    rescue NoMethodError # BasicObject
      false
    end

    def strip?
      options.fetch(:strip, true)
    end

    def adjust_output(value, _context)
      ActiveSupport::HashWithIndifferentAccess.new(value)
    end

    def convert(value)
      if value.respond_to?(:to_hash)
        value.to_hash
      else
        super
      end
    rescue NoMethodError # BasicObject
      super
    end

    # rubocop:disable Style/MissingRespondToMissing
    def method_missing(*args, &block)
      super(*args) do |klass, names, options|
        raise InvalidFilterError, 'missing attribute name' if names.empty?

        names.each do |name|
          filters[name] = klass.new(name, options, &block)
        end
      end
    end
    # rubocop:enable Style/MissingRespondToMissing

    def raw_default(*)
      value = super

      raise InvalidDefaultError, "#{name}: #{value.inspect}" if value.is_a?(Hash) && !value.empty?

      value
    end
  end
end
