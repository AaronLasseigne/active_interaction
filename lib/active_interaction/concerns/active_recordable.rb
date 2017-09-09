# frozen_string_literal: true

module ActiveInteraction
  # Implement the minimal ActiveRecord interface.
  #
  # @private
  module ActiveRecordable
    # Returns the column object for the named filter.
    #
    # @param name [Symbol] The name of a filter.
    #
    # @example
    #   class Interaction < ActiveInteraction::Base
    #     string :email, default: nil
    #
    #     def execute; end
    #   end
    #
    #   Interaction.new.column_for_attribute(:email)
    #   # => #<ActiveInteraction::FilterColumn:0x007faebeb2a6c8 @type=:string>
    #
    #   Interaction.new.column_for_attribute(:not_a_filter)
    #   # => nil
    #
    # @return [FilterColumn, nil]
    def column_for_attribute(name)
      filter = self.class.filters[name]
      FilterColumn.intern(filter.database_column_type) if filter
    end

    # Returns true if a filter of that name exists.
    #
    # @param name [String, Symbol] The name of a filter.
    #
    # @example
    #   class Interaction < ActiveInteraction::Base
    #     string :email, default: nil
    #
    #     def execute; end
    #   end
    #
    #   Interaction.new.has_attribute?(:email)
    #   # => true
    #
    #   Interaction.new.has_attribute?(:not_a_filter)
    #   # => false
    #
    # @return [Boolean]
    def has_attribute?(name) # rubocop:disable Naming/PredicateName
      self.class.filters.key?(name.to_sym)
    end
  end
end
