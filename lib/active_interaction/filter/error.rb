# frozen_string_literal: true

require 'active_support/inflector'

module ActiveInteraction
  class Filter
    # A validation error that occurs while processing the filter.
    class Error
      # @private
      def initialize(filter, type, name: nil)
        @filter = filter
        @name = name || filter.name
        @type = type

        @options = {}
        options[:type] = I18n.translate("#{Base.i18n_scope}.types.#{filter.class.slug}") if type == :invalid_type
      end

      # The filter the error occured on.
      #
      # @return [ActiveInteraction::Filter]
      attr_reader :filter

      # The name of the error.
      #
      # @return [Symbol]
      attr_reader :name

      # Options passed to the error for error message creation.
      #
      # @return [Hash]
      attr_reader :options

      # The type of error.
      #
      # @return [Symbol]
      attr_reader :type
    end
  end
end
