# coding: utf-8

# rubocop:disable Documentation
module ActiveInteraction
  class GroupedInput
    # Required for Ruby <= 1.9.3.
    def [](name)
      send(name)
    end unless method_defined?(:[])

    # Required for Ruby <= 1.9.3.
    def []=(name, value)
      send("#{name}=", value)
    end unless method_defined?(:[]=)
  end

  class Errors
    # Required for Rails < 3.2.13.
    protected :initialize_dup
  end
end
