# frozen_string_literal: true

module ActiveInteraction
  # Holds inputs passed to the interaction.
  class Inputs < DelegateClass(Hash)
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
    def group(name)
      @inputs.select { |k, _| @groups[name].include?(k) }
    end
  end
end
