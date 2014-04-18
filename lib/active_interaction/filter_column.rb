# coding: utf-8

module ActiveInteraction
  # A minimal implementation of an `ActiveRecord::ConnectionAdapters::Column`.
  #
  # @since 1.2.0
  class FilterColumn
    attr_reader :limit, :type

    class << self
      # rubocop:disable LineLength

      # Find or create the `FilterColumn` for a specific type.
      #
      # @example
      #   FilterColumn.intern(:string)
      #   # => #<ActiveInteraction::FilterColumn:0x007feeaa649c18 @type=:string>
      #
      #   FilterColumn.intern(:string)
      #   # => #<ActiveInteraction::FilterColumn:0x007feeaa649c18 @type=:string>
      #
      #   FilterColumn.intern(:boolean)
      #   # => #<ActiveInteraction::FilterColumn:0x007feeab8a0498 @type=:boolean>
      #
      # @param type [Symbol] A database column type.
      #
      # @return [FilterColumn]
      def intern(type)
        @columns ||= {}

        if @columns[type]
          @columns.fetch(type)
        else
          @columns[type] = new(type)
        end
      end
      # rubocop:enable LineLength

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
      [:integer, :float].include?(type)
    end

    # Returns `true` if the column is of type :string.
    #
    # @return [Boolean]
    def text?
      type == :string
    end
  end
end
