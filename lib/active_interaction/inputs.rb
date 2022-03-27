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
      @base = base
      @normalized_inputs = normalize(raw_inputs)
      @inputs = base.class.filters.each_with_object({}) do |(name, filter), inputs|
        inputs[name] = filter.process(@normalized_inputs[name], base)

        yield name, inputs[name] if block_given?
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

    # Returns `true` if the given key was in the hash passed to {.run}.
    # Otherwise returns `false`. Use this to figure out if an input was given,
    # even if it was `nil`. Keys within nested hash filter can also be checked
    # by passing them in series. Arrays can be checked in the same manor as
    # hashes by passing an index.
    #
    # @example
    #   class Example < ActiveInteraction::Base
    #     integer :x, default: nil
    #     def execute; given?(:x) end
    #   end
    #   Example.run!()        # => false
    #   Example.run!(x: nil)  # => true
    #   Example.run!(x: rand) # => true
    #
    # @example Nested checks
    #   class Example < ActiveInteraction::Base
    #     hash :x, default: {} do
    #       integer :y, default: nil
    #     end
    #     array :a, default: [] do
    #       integer
    #     end
    #     def execute; given?(:x, :y) || given?(:a, 2) end
    #   end
    #   Example.run!()               # => false
    #   Example.run!(x: nil)         # => false
    #   Example.run!(x: {})          # => false
    #   Example.run!(x: { y: nil })  # => true
    #   Example.run!(x: { y: rand }) # => true
    #   Example.run!(a: [1, 2])      # => false
    #   Example.run!(a: [1, 2, 3])   # => true
    #
    # @param input [#to_sym]
    #
    # @return [Boolean]
    #
    # rubocop:disable all
    def given?(input, *rest)
      filter_level = @base.class
      input_level = @normalized_inputs

      [input, *rest].each do |key_or_index|
        if key_or_index.is_a?(Symbol) || key_or_index.is_a?(String)
          key = key_or_index.to_sym
          key_to_s = key_or_index.to_s
          filter_level = filter_level.filters[key]

          break false if filter_level.nil? || input_level.nil?
          break false unless input_level.key?(key) || input_level.key?(key_to_s)

          input_level = input_level[key] || input_level[key_to_s]
        else
          index = key_or_index
          filter_level = filter_level.filters.first.last

          break false if filter_level.nil? || input_level.nil?
          break false unless index.between?(-input_level.size, input_level.size - 1)

          input_level = input_level[index]
        end
      end && true
    end
    # rubocop:enable all

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
