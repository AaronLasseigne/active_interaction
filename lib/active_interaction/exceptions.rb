# frozen_string_literal: true

module ActiveInteraction
  # Top-level error class. All other errors subclass this.
  Error = Class.new(StandardError)

  # Raised if a constant name is invalid.
  InvalidNameError = Class.new(Error)

  # Raised if a converter is invalid.
  InvalidConverterError = Class.new(Error)

  # Raised if a default value is invalid.
  InvalidDefaultError = Class.new(Error)

  # Raised if a filter has an invalid definition.
  InvalidFilterError = Class.new(Error)

  # Raised if an interaction is invalid.
  class InvalidInteractionError < Error
    # The interaction where the error occured.
    #
    # @return [ActiveInteraction::Base]
    attr_accessor :interaction
  end

  # Raised if a filter cannot be found.
  MissingFilterError = Class.new(Error)

  # Raised if there is no default value.
  NoDefaultError = Class.new(Error)

  # Used by {Runnable} to signal a failure when composing.
  #
  # @private
  class Interrupt < Error
    attr_reader :errors

    # @param errors [Runnable]
    def initialize(errors)
      super()

      @errors = errors
    end
  end
  private_constant :Interrupt
end
