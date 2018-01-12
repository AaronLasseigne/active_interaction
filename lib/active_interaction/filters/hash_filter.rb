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

    private

    def matches?(value)
      value.is_a?(Hash)
    rescue NoMethodError
      false
    end

    def adjust_output(value, context)
      value = value.with_indifferent_access
      initial = strip? ? ActiveSupport::HashWithIndifferentAccess.new : value

      filters.each_with_object(initial) do |(name, filter), h|
        h[name.to_s] = clean_value(name.to_s, filter, value, context)
      end
    end

    def convert(value)
      if value.respond_to?(:to_hash)
        value.to_hash
      else
        value
      end
    rescue NoMethodError
      false
    end

    def clean_value(name, filter, value, context)
      filter.clean(value[name], context)
    rescue InvalidValueError, MissingValueError
      raise InvalidNestedValueError.new(name, value[name])
    end

    def strip?
      options.fetch(:strip, true)
    end

    def raw_default(*)
      value = super

      if value.is_a?(Hash) && !value.empty?
        raise InvalidDefaultError, ErrorMessage.new(
          issue: {
            desc: %(Hashes can only have a default value of "nil" or "{}". If you need default values for keys, set the hash default to "{}" and set the default values on the nested filters.),
            code: source_str,
            lines: [0]
          }
        )
      end

      value
    end

    def method_missing(*args, &block) # rubocop:disable Style/MethodMissing
      super(*args) do |klass, names, options|
        error_inner_filter_unnamed(klass, options, &block) if names.empty?

        names.each do |name|
          filters[name] = klass.new(name, options, &block)
        end

        error_inner_filter_using_groups if options.key?(:groups)
      end
    end

    # rubocop:disable Metrics/AbcSize
    def error_inner_filter_unnamed(klass, inner_options, &inner_block)
      fixed_filter = self.class.new(name, options) {}
      filters.each do |name, filter|
        fixed_filter.filters[name] = filter
      end
      fixed_filter.filters[:'<name>'] =
        klass.new(:'<name>', inner_options, &inner_block)

      filters[:'0'] = klass.new(nil, inner_options, &inner_block)

      raise InvalidFilterError, ErrorMessage.new(
        issue: {
          desc: 'Nested filters need to be named.',
          code: source_str,
          lines: [filters.size]
        },
        fix: {
          desc: 'This can be fixed by passing a name as the first argument to the filter.',
          code: fixed_filter.source_str
        }
      )
    end
    # rubocop:enable Metrics/AbcSize

    def error_inner_filter_using_groups
      raise InvalidFilterError, ErrorMessage.new(
        issue: {
          desc: %q(Inner hash filters can't be referenced so they can't belong to a group.),
          code: source_str,
          lines: [1]
        },
        fix: {
          if: -> { !options[:groups] },
          desc: %q(If you're trying to set groups for the entire hash, that can be done at the hash level.),
          code: source_str
            .gsub(/,? groups:.*?(?:,|$)/, '')
            .sub(/ do/, ", groups: #{filters.first.last.groups.inspect} do")
        }
      )
    end
  end
end
