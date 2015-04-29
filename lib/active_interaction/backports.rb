# coding: utf-8

module ActiveInteraction
  class GroupedInput # rubocop:disable Style/Documentation
    # Required for Ruby <= 1.9.3.
    def [](name)
      send(name)
    end unless method_defined?(:[])

    # Required for Ruby <= 1.9.3.
    def []=(name, value)
      send("#{name}=", value)
    end unless method_defined?(:[]=)
  end

  class Errors # rubocop:disable Style/Documentation
    # Required for Rails < 3.2.13.
    protected :initialize_dup
  end

  class HashFilter # rubocop:disable Style/Documentation
    # Required for Rails < 4.0.0.
    def self.transform_keys(hash, &block)
      return hash.transform_keys(&block) if hash.respond_to?(:transform_keys)

      result = {}
      hash.each_key { |key| result[block.call(key)] = hash[key] }
      result
    end
  end
end
