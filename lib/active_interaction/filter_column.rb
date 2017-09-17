# frozen_string_literal: true

module ActiveInteraction
  # A minimal implementation of an `ActiveRecord::ConnectionAdapters::Column`.
  #
  # @since 1.2.0
  class FilterColumn
    # @return [nil]
    attr_reader :limit

    # @return [Symbol]
    attr_reader :type

    class << self
      # Find or create the `FilterColumn` for a specific type.
      #
      # @param type [Symbol] A database column type.
      #
      # @example
      #   FilterColumn.intern(:string)
      #   # => #<ActiveInteraction::FilterColumn:0x007feeaa649c @type=:string>
      #
      #   FilterColumn.intern(:string)
      #   # => #<ActiveInteraction::FilterColumn:0x007feeaa649c @type=:string>
      #
      #   FilterColumn.intern(:boolean)
      #   # => #<ActiveInteraction::FilterColumn:0x007feeab8a08 @type=:boolean>
      #
      # @return [FilterColumn]
      def intern(type)
        @columns ||= {}
        @columns[type] ||= new(type)
      end

      private :new # rubocop:disable Style/AccessModifierDeclarations
    end

    # @param type [type] The database column type.
    #
    # @private
    def initialize(type)
      @type = type
    end

    # Returns `true` if the column is either of type :integer or :float.
    #
    # @return [Boolean]
    def number?
      %i[integer float].include?(type)
    end

    # Returns `true` if the column is of type :string.
    #
    # @return [Boolean]
    def text?
      type == :string
    end
  end
end
