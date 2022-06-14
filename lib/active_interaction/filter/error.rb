# frozen_string_literal: true

require 'active_support/inflector'

module ActiveInteraction
  class Filter
    # A validation error that occurs during the process of creating the filter.
    class Error
      def initialize(filter, type)
        @name = filter.name
        @type = type
      end

      attr_reader :name, :type
    end
  end
end
