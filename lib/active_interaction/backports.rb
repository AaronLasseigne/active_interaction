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
end

# @private
class Hash
  # Required for Rails < 4.0.0.
  def transform_keys
    result = {}
    each_key do |key|
      result[yield(key)] = self[key]
    end
    result
  end unless method_defined?(:transform_keys)
end
