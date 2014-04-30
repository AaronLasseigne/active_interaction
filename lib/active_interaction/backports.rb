# coding: utf-8

# rubocop:disable Documentation
module ActiveInteraction
  class GroupedInput
    # Remove when Ruby > 1.9.3.
    def [](name)
      send(name)
    end unless method_defined?(:[])

    # Remove when Ruby > 1.9.3.
    def []=(name, value)
      send("#{name}=", value)
    end unless method_defined?(:[]=)
  end
end

class Hash
  # Remove when Rails > 4.0.2.
  def transform_keys
    result = {}
    each_key do |key|
      result[yield(key)] = self[key]
    end
    result
  end unless method_defined?(:transform_keys)
end
