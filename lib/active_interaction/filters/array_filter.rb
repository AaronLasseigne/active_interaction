# frozen_string_literal: true

module ActiveInteraction
  class Base # rubocop:disable Lint/EmptyClass
    # @!method self.array(*attributes, options = {}, &block)
    #   Creates accessors for the attributes and ensures that values passed to
    #     the attributes are Arrays.
    #
    #   @!macro filter_method_params
    #   @param block [Proc] filter method to apply to each element
    #   @option options [Boolean] :index_errors (ActiveRecord.index_nested_attribute_errors) returns errors with an
    #     index
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

    # The array starts with the class override key and then contains any
    # additional options which halt explicit setting of the class.
    FILTER_NAME_OR_OPTION = {
      'ActiveInteraction::ObjectFilter' => [:class].freeze,
      'ActiveInteraction::RecordFilter' => [:class].freeze,
      'ActiveInteraction::InterfaceFilter' => %i[from methods].freeze
    }.freeze
    private_constant :FILTER_NAME_OR_OPTION

    register :array

    def process(value, context)
      input = super

      return ArrayInput.new(value: input.value, error: input.error) if input.error
      return ArrayInput.new(value: default(context), error: input.error) if input.value.nil?

      value = input.value
      error = nil
      children = []

      unless filters.empty?
        value.map.with_index do |item, i|
          filters[:'0'].process(item, context).tap do |result|
            if !error && result.error
              error = InvalidValueError.new(index_error: index_errors?)
              error.index = i
            end
            children.push(result)
          end
        end
      end

      ArrayInput.new(value: value, error: error, children: children)
    end

    private

    def index_errors?
      default =
        if ::ActiveRecord.respond_to?(:index_nested_attribute_errors)
          ::ActiveRecord.index_nested_attribute_errors # Moved to here in Rails 7.0
        else
          ::ActiveRecord::Base.index_nested_attribute_errors
        end
      options.fetch(:index_errors, default)
    end

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
    rescue NoMethodError # BasicObject
      false
    end

    def adjust_output(value, _context)
      value.to_a
    end

    def convert(value)
      if value.respond_to?(:to_ary)
        value.to_ary
      else
        super
      end
    rescue NoMethodError # BasicObject
      super
    end

    def add_option_in_place_of_name(klass, options)
      if (keys = FILTER_NAME_OR_OPTION[klass.to_s]) && (keys & options.keys).empty?
        options.merge(
          "#{keys.first}": name.to_s.singularize.camelize.to_sym
        )
      else
        options
      end
    end

    # rubocop:disable Style/MissingRespondToMissing
    def method_missing(*, &block)
      super do |klass, names, options|
        options = add_option_in_place_of_name(klass, options)

        filter = klass.new(names.first || '', options, &block)

        filters[filters.size.to_s.to_sym] = filter

        validate!(names)
      end
    end
    # rubocop:enable Style/MissingRespondToMissing

    # @param filter [Filter]
    # @param names [Array<Symbol>]
    #
    # @raise [InvalidFilterError]
    def validate!(names)
      raise InvalidFilterError, 'multiple filters in array block' if filters.size > 1

      raise InvalidFilterError, 'attribute names in array block' unless names.empty?

      nil
    end
  end
end
