# coding: utf-8

begin
  require 'active_record'
rescue LoadError
end

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
    #   @example
    #     array :ids do
    #       integer default: nil
    #     end
  end

  # @private
  class ArrayFilter < Filter
    include Missable

    register :array

    def cast(value)
      case value
      when *classes
        return value if filters.empty?

        filter = filters.values.first
        value.map { |e| filter.clean(e) }
      else
        super
      end
    end

    def method_missing(*, &block)
      super do |klass, names, options|
        filter = klass.new(name.to_s.singularize.to_sym, options, &block)

        validate(filter, names)

        filters[filter.name] = filter
      end
    end

    private

    # @return [Array<Class>]
    def classes
      result = [Array]
      return result unless Object.const_defined?(:ActiveRecord)
      return result unless ActiveRecord.const_defined?(:Relation)

      result.push(ActiveRecord::Relation)
    end

    # @param filter [Filter]
    # @param names [Array<Symbol>]
    #
    # @raise [InvalidFilterError]
    def validate(filter, names)
      unless filters.empty?
        fail InvalidFilterError, 'multiple filters in array block'
      end

      unless names.empty?
        fail InvalidFilterError, 'attribute names in array block'
      end

      # rubocop:disable GuardClause
      if filter.default?
        fail InvalidDefaultError, 'default values in array block'
      end
      # rubocop:enable GuardClause
    end
  end
end
