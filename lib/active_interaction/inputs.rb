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

      # @param inputs [Hash, ActionController::Parameters, ActiveInteraction::Inputs] Attribute values to set.
      #
      # @private
      def process(inputs)
        normalize_inputs!(inputs)
          .stringify_keys
          .sort
          .each_with_object({}) do |(k, v), h|
            next if reserved?(k)

            if (group = GROUPED_INPUT_PATTERN.match(k))
              assign_to_grouped_input!(h, group[:key], group[:index], v)
            else
              h[k.to_sym] = v
            end
          end
      end

      private

      def normalize_inputs!(inputs)
        return inputs if inputs.is_a?(Hash) || inputs.is_a?(Inputs)

        parameters = 'ActionController::Parameters'
        klass = parameters.safe_constantize
        return inputs.to_unsafe_h if klass && inputs.is_a?(klass)

        raise ArgumentError, "inputs must be a hash or #{parameters}"
      end

      def assign_to_grouped_input!(inputs, key, index, value)
        key = key.to_sym

        inputs[key] = GroupedInput.new unless inputs[key].is_a?(GroupedInput)
        inputs[key][index] = value
      end
    end

    def initialize(inputs = {})
      super(inputs)
    end
  end
end
