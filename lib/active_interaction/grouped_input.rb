# coding: utf-8

require 'ostruct'

module ActiveInteraction
  # Holds a group of inputs together for passing from {Base} to {Filter}s.
  #
  # @since 1.2.0
  #
  # @private
  class GroupedInput < OpenStruct
    def [](name)
      send(name)
    end unless method_defined?(:[])

    def []=(name, value)
      send("#{name}=", value)
    end unless method_defined?(:[]=)
  end
end
