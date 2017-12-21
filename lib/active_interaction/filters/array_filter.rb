# frozen_string_literal: true

module ActiveInteraction
  class Base
    # @!method self.array(*attributes, options = {}, &block)
    #   Creates accessors for the attributes and ensures that values passed to
    #     the attributes are Arrays.
    #
    #   @!macro filter_method_params
    #   @param block [Proc] filter method to apply to each element
    #
    #   @example
    #     array :ids
    #   @example
    #     array :ids do
    #       integer
    #     end
  end

  # @private
  class ArrayFilter < Filter
    include Missable

    register :array

    private

    def klasses
      %w[
        ActiveRecord::Relation
        ActiveRecord::Associations::CollectionProxy
      ].each_with_object([Array]) do |name, result|
        next unless (klass = name.safe_constantize)
        result.push(klass)
      end
    end

    def matches?(value)
      klasses.any? { |klass| value.is_a?(klass) }
    rescue NoMethodError
      false
    end

    def adjust_output(value, context)
      return value if filters.empty?

      filter = filters.values.first
      value.map { |e| filter.clean(e, context) }
    end

    def convert(value)
      if value.respond_to?(:to_ary)
        value.to_ary
      else
        value
      end
    rescue NoMethodError
      false
    end

    def add_option_in_place_of_name(klass, options)
      filter_name_or_option = {
        ObjectFilter    => :class,
        RecordFilter    => :class,
        InterfaceFilter => :from
      }
      if (key = filter_name_or_option[klass]) && !options.key?(key)
        options.merge(
          :"#{key}" => name.to_s.singularize.camelize.to_sym
        )
      else
        options
      end
    end

    def method_missing(*, &block) # rubocop:disable Style/MethodMissing
      super do |klass, names, options|
        options = add_option_in_place_of_name(klass, options)

        filter = klass.new(names.first || '', options, &block)

        filters[filters.size.to_s.to_sym] = filter

        validate!(filter, names)
      end
    end

    # @param filter [Filter]
    # @param names [Array<Symbol>]
    #
    # @raise [InvalidFilterError]
    def validate!(filter, names)
      if filters.size > 1
        raise InvalidFilterError, 'multiple filters in array block'
      end

      unless names.empty?
        raise InvalidFilterError, 'attribute names in array block'
      end

      unless filter.groups.empty?
        raise InvalidFilterError, 'nested filters can not be a part of a group'
      end

      if filter.default?
        raise InvalidDefaultError, 'default values in array block'
      end

      nil
    end
  end
end
