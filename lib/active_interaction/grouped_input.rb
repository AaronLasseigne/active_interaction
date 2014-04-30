# coding: utf-8

require 'ostruct'

module ActiveInteraction
  # Holds a group of inputs together for passing from {Base} to {Filter}s.
  #
  # @private
  class GroupedInput < OpenStruct
    unless method_defined?(:[])
      def [](name)
        send(name)
      end
    end

    unless method_defined?(:[]=)
      def []=(name, value)
        send("#{name}=", value)
      end
    end
  end
end
