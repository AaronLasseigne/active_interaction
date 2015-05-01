# coding: utf-8

#
module ActiveInteraction
  # Top-level error class. All other errors subclass this.
  #
  # @return [Class]
  Error = Class.new(StandardError)

  # Raised if a class name is invalid.
  #
  # @return [Class]
  InvalidClassError = Class.new(Error)

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
  InvalidInteractionError = Class.new(Error)

  # Raised if a user-supplied value is invalid.
  #
  # @return [Class]
  InvalidValueError = Class.new(Error)

  # Raised if a filter cannot be found.
  #
  # @return [Class]
  MissingFilterError = Class.new(Error)

  # Raised if no value is given.
  #
  # @return [Class]
  MissingValueError = Class.new(Error)

  # Raised if there is no default value.
  #
  # @return [Class]
  NoDefaultError = Class.new(Error)

  # Raised if a reserved name is used.
  #
  # @return [Class]
  #
  # @since 1.2.0
  ReservedNameError = Class.new(Error)

  # Raised if a user-supplied value to a nested hash input is invalid.
  #
  # @return [Class]
  class InvalidNestedValueError < Error
    # @return [Symbol]
    attr_reader :filter_name

    # @return [Object]
    attr_reader :input_value

    # @param filter_name [Symbol]
    # @param input_value [Object]
    def initialize(filter_name, input_value)
      super("#{filter_name}: #{input_value.inspect}")

      @filter_name = filter_name
      @input_value = input_value
    end
  end

  # Used by {Runnable} to signal a failure when composing.
  #
  # @private
  class Interrupt < Error
    attr_reader :outcome

    # @param outcome [Runnable]
    def initialize(outcome)
      super()

      @outcome = outcome
    end
  end
  private_constant :Interrupt

  # An extension that provides symbolic error messages to make introspection
  #   and testing easier.
  class Errors < ActiveModel::Errors
    # Maps attributes to arrays of symbolic messages.
    #
    # @return [Hash{Symbol => Array<Symbol>}]
    attr_reader :symbolic
    ActiveInteraction.deprecate self, :symbolic, 'use `details` instead'

    def details
      @symbolic.each_with_object(Hash.new([])) do |(k, vs), h|
        vs.each { |v| h[k] += [{ error: v }] }
      end
    end

    alias_method :add_without_details, :add
    def add_with_details(attribute, message = :invalid, options = {})
      message = message.call if message.respond_to?(:call)
      @symbolic[attribute] += [message] if message.is_a?(Symbol)
      add_without_details(attribute, message, options)
    end
    alias_method :add, :add_with_details

    # Adds a symbolic error message to an attribute.
    #
    # @example
    #   errors.add_sym(:attribute)
    #   errors.details
    #   # => {:attribute=>[{:error=>:invalid}]}
    #   errors.messages
    #   # => {:attribute=>["is invalid"]}
    #
    # @param attribute [Symbol] The attribute to add an error to.
    # @param symbol [Symbol, nil] The symbolic error to add.
    # @param message [String, Symbol, Proc, nil] The message to add.
    # @param options [Hash]
    #
    # @return (see #symbolic)
    #
    # @see ActiveModel::Errors#add
    def add_sym(attribute, symbol = :invalid, message = nil, options = {})
      add_without_details(attribute, message || symbol, options)

      @symbolic[attribute] += [symbol]
    end
    ActiveInteraction.deprecate self, :add_sym, 'use `add` instead'

    # @see ActiveModel::Errors#initialize
    #
    # @private
    def initialize(*)
      @symbolic = Hash.new([]).with_indifferent_access

      super
    end

    # @see ActiveModel::Errors#initialize_dup
    #
    # @private
    def initialize_dup(other)
      @symbolic = Hash.new([]).with_indifferent_access
      other.details.each { |k, vs| vs.each { |v| @symbolic[k] += [v[:error]] } }

      super
    end

    # @see ActiveModel::Errors#clear
    #
    # @private
    def clear
      @symbolic.clear

      super
    end

    # Merge other errors into this one.
    #
    # @param other [Errors]
    #
    # @return [Errors]
    def merge!(other)
      merge_messages!(other)
      merge_details!(other) if other.respond_to?(:details)
      self
    end

    private

    def merge_messages!(other)
      other.messages.each do |attribute, messages|
        messages.each do |message|
          add(attribute, message) unless added?(attribute, message)
        end
      end
    end

    def merge_details!(other)
      other.details.each do |attribute, hashes|
        hashes.each do |hash|
          error = hash[:error]
          next if @symbolic[attribute].include?(error)

          @symbolic[attribute] += [error]
        end
      end
    end
  end
end
