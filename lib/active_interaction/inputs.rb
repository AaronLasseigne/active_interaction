# frozen_string_literal: true

require 'forwardable'

module ActiveInteraction
  # Holds inputs passed to the interaction.
  class Inputs
    include Enumerable
    extend Forwardable

    # matches inputs like "key(1i)"
    GROUPED_INPUT_PATTERN = /
      \A
      (?<key>.+)         # extracts "key"
      \((?<index>\d+)i\) # extracts "1"
      \z
    /x.freeze
    private_constant :GROUPED_INPUT_PATTERN

    class << self
      # @private
      def keys_for_group?(keys, group_key)
        search_key = /\A#{group_key}\(\d+i\)\z/
        keys.any? { |key| search_key.match?(key) }
      end

      # Checking `syscall` is the result of what appears to be a bug in Ruby.
      # https://bugs.ruby-lang.org/issues/15597
      # @private
      def reserved?(name)
        name.to_s.start_with?('_interaction_') ||
          name == :syscall ||
          (
            Base.method_defined?(name) &&
            !Object.method_defined?(name)
          ) ||
          (
            Base.private_method_defined?(name) &&
            !Object.private_method_defined?(name)
          )
      end
    end

    # @private
    def initialize(raw_inputs, base)
      @raw_inputs = raw_inputs
      @normalized_inputs = normalize(raw_inputs)
      @inputs = base.class.filters.each_with_object({}) do |(name, filter), inputs|
        inputs[name] = filter.process(@normalized_inputs[name], base)

        yield name, inputs[name]
      end
    end

    # @private
    def normalized
      @normalized_inputs
    end

    def to_h
      @to_h ||= @inputs.transform_values(&:value).freeze
    end

    def_delegators :to_h,
      :[],
      :dig,
      :each,
      :each_key,
      :each_pair,
      :each_value,
      :empty?,
      :except,
      :fetch,
      :fetch_values,
      :filter,
      :flatten,
      :has_key?,
      :has_value?,
      :include?,
      :inspect,
      :key,
      :key?,
      :keys,
      :length,
      :member?,
      :merge,
      :rassoc,
      :reject,
      :select,
      :size,
      :slice,
      :store,
      :to_a,
      :to_s,
      :value?,
      :values,
      :values_at

    private

    def normalize(inputs)
      convert(inputs)
        .sort
        .each_with_object({}) do |(k, v), h|
          next if self.class.reserved?(k)

          if (group = GROUPED_INPUT_PATTERN.match(k))
            assign_to_grouped_input!(h, group[:key], group[:index], v)
          else
            h[k.to_sym] = v
          end
        end
    end

    def convert(inputs)
      return inputs.stringify_keys if inputs.is_a?(Hash)
      return inputs if inputs.is_a?(Inputs)
      return inputs.to_unsafe_h.stringify_keys if inputs.is_a?(ActionController::Parameters)

      raise ArgumentError, 'inputs must be a hash or ActionController::Parameters'
    end

    def assign_to_grouped_input!(inputs, key, index, value)
      key = key.to_sym

      inputs[key] = GroupedInput.new unless inputs[key].is_a?(GroupedInput)
      inputs[key][index] = value
    end
  end
end
