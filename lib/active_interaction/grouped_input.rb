# coding: utf-8

require 'ostruct'

module ActiveInteraction
  # Holds a group of inputs together for passing from {Base} to {Filter}s.
  #
  # @private
  class GroupedInput < OpenStruct
    def [](name)
      return super if self.class.superclass.method_defined?(:[])

      send(name)
    end

    def []=(name, value)
      return super if self.class.superclass.method_defined?(:[]=)

      send("#{name}=", value)
    end
  end
end
