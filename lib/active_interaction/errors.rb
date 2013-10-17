module ActiveInteraction
  InteractionInvalid = Class.new(StandardError)
  InvalidDefaultValue = Class.new(StandardError)
  InvalidNestedValue = Class.new(StandardError)
  InvalidValue = Class.new(StandardError)
  MissingValue = Class.new(StandardError)

  # A small extension to provide symbolic error messages to make introspecting
  #   and testing easier.
  class Errors < ActiveModel::Errors
    # A hash mapping attributes to arrays of symbolic messages.
    #
    # @return [Hash{Symbol => Array<Symbol>}]
    attr_reader :symbolic

    # Adds a symbolic error message to an attribute.
    #
    # @example
    #   errors.add_sym(:attribute)
    #   errors.symbolic
    #   # => {:attribute=>[:invalid]}
    # @param attribute [Symbol] The attribute to add an error to.
    # @param symbol [Symbol] The symbolic error to add.
    # @param message [String, Symbol, Proc]
    # @param options [Hash]
    # @return [Hash{Symbol => Array<String>}]
    # @see ActiveModel::Errors#add
    def add_sym(attribute, symbol = :invalid, message = nil, options = {})
      symbolic[attribute] ||= []
      symbolic[attribute] << symbol

      add(attribute, message || symbol, options)
    end

    # @private
    def initialize(*args)
      @symbolic = {}
      super
    end

    # @private
    def initialize_dup(other)
      @symbolic = other.symbolic.dup
      super
    end

    # @private
    def clear
      symbolic.clear
      super
    end
  end
end
