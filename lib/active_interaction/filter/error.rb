# frozen_string_literal: true

require 'active_support/inflector'

module ActiveInteraction
  class Filter
    # A validation error that occurs during the process of creating the filter.
    class Error
      def initialize(filter, type)
        @name = filter.name
        @type = type

        @options = {}
        options[:type] = I18n.translate("#{Base.i18n_scope}.types.#{filter.class.slug}") if type == :invalid_type
      end

      attr_reader :name, :type, :options
    end

    # An indexed validation error that occurs during the process of creating the
    # filter.
    class IndexedError < Error
      def initialize(name, type, index, index_error: false)
        super(name, type)

        @index = index
        @index_error = index_error
      end

      attr_reader :index

      def index_error?
        @index_error
      end

      def name
        index_error? ? :"#{@name}[#{index}]" : @name
      end
    end
  end
end
