# coding: utf-8

module ActiveInteraction
  # Functionality common between {Base}.
  #
  # @see Base
  module Core
    # Get or set the description.
    #
    # @example
    #   core.desc
    #   # => nil
    #   core.desc('descriptive!')
    #   core.desc
    #   # => "descriptive!"
    #
    # @param desc [String, nil] what to set the description to
    #
    # @return [String, nil] the description
    #
    # @since 0.8.0
    def desc(desc = nil)
      if desc.nil?
        unless instance_variable_defined?(:@_interaction_desc)
          @_interaction_desc = nil
        end
      else
        @_interaction_desc = desc
      end

      @_interaction_desc
    end
  end
end
