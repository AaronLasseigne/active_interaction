# frozen_string_literal: true

require 'active_support/inflector'

module ActiveInteraction
  class Filter
    # A validation error that occurs during the process of creating the filter.
    class Error
      def initialize(filter, type, name: nil)
        @filter = filter
        @name = name || filter.name
        @type = type

        @options = {}
        options[:type] = I18n.translate("#{Base.i18n_scope}.types.#{filter.class.slug}") if type == :invalid_type
      end

      attr_reader :filter, :name, :type, :options
    end
  end
end
