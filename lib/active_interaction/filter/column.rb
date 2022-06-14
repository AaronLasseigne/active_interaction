# frozen_string_literal: true

module ActiveInteraction
  class Filter
    # A minimal implementation of an `ActiveRecord::ConnectionAdapters::Column`.
    class Column
      # @return [nil]
      attr_reader :limit

      # @return [Symbol]
      attr_reader :type

      class << self
        # Find or create the `Filter::Column` for a specific type.
        #
        # @param type [Symbol] A database column type.
        #
        # @example
        #   Filter::Column.intern(:string)
        #   # => #<ActiveInteraction::Filter::Column:0x007feeaa649c @type=:string>
        #
        #   Filter::Column.intern(:string)
        #   # => #<ActiveInteraction::Filter::Column:0x007feeaa649c @type=:string>
        #
        #   Filter::Column.intern(:boolean)
        #   # => #<ActiveInteraction::Filter::Column:0x007feeab8a08 @type=:boolean>
        #
        # @return [Filter::Column]
        def intern(type)
          @columns ||= {}
          @columns[type] ||= new(type)
        end

        private :new
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
end
