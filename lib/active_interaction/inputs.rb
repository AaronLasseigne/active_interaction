# frozen_string_literal: true

module ActiveInteraction
  # Holds inputs passed to the interaction.
  class Inputs < DelegateClass(Hash)
    class << self
      # matches inputs like "key(1i)"
      GROUPED_INPUT_PATTERN = /
        \A
        (?<key>.+)         # extracts "key"
        \((?<index>\d+)i\) # extracts "1"
        \z
      /x.freeze
      private_constant :GROUPED_INPUT_PATTERN

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

      # @private
      def process(inputs)
        inputs.stringify_keys.sort.each_with_object({}) do |(k, v), h|
          next if reserved?(k)

          if (group = GROUPED_INPUT_PATTERN.match(k))
            assign_to_grouped_input!(h, group[:key], group[:index], v)
          else
            h[k.to_sym] = v
          end
        end
      end

      private

      def assign_to_grouped_input!(inputs, key, index, value)
        key = key.to_sym

        inputs[key] = GroupedInput.new unless inputs[key].is_a?(GroupedInput)
        inputs[key][index] = value
      end
    end

    def initialize
      @groups = {}
      @groups.default_proc = ->(hash, key) { hash[key] = [] }

      super(@inputs = {})
    end

    # Associates the `value` with the `key`. Allows the `key`/`value` pair to
    #   be associated with one or more groups.
    #
    # @example
    #   inputs.store(:key, :value)
    #   # => :value
    #   inputs.store(:key, :value, %i[a b])
    #   # => :value
    #
    # @param key [Object] The key to store the value under.
    # @param value [Object] The value to store.
    # @param groups [Array<Object>] The groups to store the pair under.
    #
    # @return [Object] value
    # @private
    def store(key, value, groups = [])
      groups.each do |group|
        @groups[group] << key
      end

      super(key, value)
    end

    # Returns inputs from the group name given.
    #
    # @example
    #   inputs.group(:a)
    #   # => {key: :value}
    #
    # @param name [Object] Name of the group to return.
    #
    # @return [Hash] Inputs from the group name given.
    # @private
    def group(name)
      @inputs.select { |k, _| @groups[name].include?(k) }
    end
  end
end
