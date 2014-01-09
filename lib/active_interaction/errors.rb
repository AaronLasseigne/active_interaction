# coding: utf-8

module ActiveInteraction # rubocop:disable Documentation
  # Top-level error class. All other errors subclass this.
  Error = Class.new(StandardError)

  # Raised if a class name is invalid.
  InvalidClassError = Class.new(Error)

  # Raised if a default value is invalid.
  InvalidDefaultError = Class.new(Error)

  # Raised if a filter has an invalid definition.
  InvalidFilterError = Class.new(Error)

  # Raised if an interaction is invalid.
  InvalidInteractionError = Class.new(Error)

  # Raised if a user-supplied value is invalid.
  InvalidValueError = Class.new(Error)

  # Raised if a filter cannot be found.
  MissingFilterError = Class.new(Error)

  # Raised if no value is given.
  MissingValueError = Class.new(Error)

  # Raised if there is no default value.
  NoDefaultError = Class.new(Error)

  # @private
  class Interrupt < Error
    attr_reader :outcome

    def initialize(outcome)
      super()

      @outcome = outcome
    end
  end
  private_constant :Interrupt

  # A small extension to provide symbolic error messages to make introspecting
  #   and testing easier.
  #
  # @since 0.6.0
  class Errors < ActiveModel::Errors
    # A hash mapping attributes to arrays of symbolic messages.
    #
    # @return [Hash{Symbol => Array<Symbol>}]
    attr_reader :symbolic

    # Adds a symbolic error message to an attribute.
    #
    # @param attribute [Symbol] The attribute to add an error to.
    # @param symbol [Symbol] The symbolic error to add.
    # @param message [String, Symbol, Proc]
    # @param options [Hash]
    #
    # @example Adding a symbolic error.
    #   errors.add_sym(:attribute)
    #   errors.symbolic
    #   # => {:attribute=>[:invalid]}
    #   errors.messages
    #   # => {:attribute=>["is invalid"]}
    #
    # @return [Hash{Symbol => Array<Symbol>}]
    #
    # @see ActiveModel::Errors#add
    def add_sym(attribute, symbol = :invalid, message = nil, options = {})
      add(attribute, message || symbol, options)

      symbolic[attribute] ||= []
      symbolic[attribute] << symbol
    end

    # @private
    def initialize(*args)
      @symbolic = {}.with_indifferent_access
      super
    end

    # @private
    def initialize_dup(other)
      @symbolic = other.symbolic.with_indifferent_access
      super
    end

    # @private
    def clear
      symbolic.clear
      super
    end

    # Merge other errors into this one.
    #
    # @param other [Errors]
    #
    # @return [Errors]
    def merge!(other)
      other.symbolic.each do |attribute, symbols|
        symbols.each { |s| add_sym(attribute, s) }
      end

      other.messages.each do |attribute, messages|
        messages.each { |m| add(attribute, m) unless added?(attribute, m) }
      end

      self
    end
  end
end
