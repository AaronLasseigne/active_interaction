# frozen_string_literal: true

module ActiveInteraction
  # Top-level error class. All other errors subclass this.
  #
  # @return [Class]
  Error = Class.new(StandardError)

  # Raised if a constant name is invalid.
  #
  # @return [Class]
  InvalidNameError = Class.new(Error)

  # Raised if a converter is invalid.
  #
  # @return [Class]
  InvalidConverterError = Class.new(Error)

  # Raised if a default value is invalid.
  #
  # @return [Class]
  InvalidDefaultError = Class.new(Error)

  # Raised if a filter has an invalid definition.
  #
  # @return [Class]
  InvalidFilterError = Class.new(Error)

  # Raised if an interaction is invalid.
  #
  # @return [Class]
  class InvalidInteractionError < Error
    attr_accessor :interaction
  end

  # Raised if a filter cannot be found.
  #
  # @return [Class]
  MissingFilterError = Class.new(Error)

  # Raised if there is no default value.
  #
  # @return [Class]
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
