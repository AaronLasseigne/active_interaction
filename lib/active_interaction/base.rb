require 'active_support/core_ext/hash/indifferent_access'

module ActiveInteraction
  # @abstract Subclass and override {#execute} to implement a custom
  #   ActiveInteraction class.
  #
  # @example
  #   class ExampleInteraction < ActiveInteraction::Base
  #     # Required
  #     integer :a, :b
  #
  #     # Optional
  #     integer :c, default: nil
  #
  #     def execute
  #       sum = a + b
  #       c.nil? ? sum : sum + c
  #     end
  #   end
  #
  #   outcome = ExampleInteraction.run(a: 1, b: 2, c: 3)
  #   if outcome.valid?
  #     p outcome.result
  #   else
  #     p outcome.errors
  #   end
  class Base
    include ActiveModel

    extend Core
    extend MethodMissing
    extend OverloadHash

    validate :input_errors, :runtime_errors

    # Returns the inputs provided to {.run} or {.run!} after being cast based
    #   on the filters in the class.
    #
    # @return [Hash{Symbol => Object}] All inputs passed to {.run} or {.run!}.
    #
    # @since 0.6.0
    def inputs
      self.class.filters.reduce({}) do |h, filter|
        h[filter.name] = send(filter.name)
        h
      end
    end

    # @param options [Hash{Symbol => Object}] Attribute values to set.
    #
    # @private
    def initialize(options = {})
      options = options.symbolize_keys

      options.each do |key, value|
        if key.to_s.start_with?('_interaction_')
          raise InvalidValueError, key.inspect
        end

        instance_variable_set("@#{key}", value)
      end

      self.class.filters.each do |filter|
        begin
          send("#{filter.name}=", filter.clean(options[filter.name]))
        rescue InvalidValueError, MissingValueError
        end
      end
    end

    # Runs the business logic associated with the interaction. The method is
    #   only run when there are no validation errors. The return value is
    #   placed into {#result}. This method must be overridden in the subclass.
    #   This method is run in a transaction if ActiveRecord is available.
    #
    # @raise [NotImplementedError] if the method is not defined.
    #
    # @abstract
    def execute
      raise NotImplementedError
    end

    # Returns the output from {#execute} if there are no validation errors or
    #   `nil` otherwise.
    #
    # @return [Nil] if there are validation errors.
    # @return [Object] if there are no validation errors.
    def result
      symbol = :'@_interaction_result'
      if instance_variable_defined?(symbol)
        instance_variable_get(symbol)
      else
        nil
      end
    end

    # @private
    def errors
      @_interaction_errors ||= Errors.new(self)
    end

    # @private
    def valid?(*args)
      super(*args) || (@_interaction_result = nil)
    end

    # Get all the filters defined on this interaction.
    #
    # @return [Filters]
    #
    # @since 0.6.0
    def self.filters
      @_interaction_filters ||= Filters.new
    end

    # Runs validations and if there are no errors it will call {#execute}.
    #
    # @param (see #initialize)
    #
    # @return [ActiveInteraction::Base] An instance of the class `run` is
    #   called on.
    def self.run(*args)
      new(*args).tap do |interaction|
        if interaction.valid?
          result = transaction { interaction.execute }

          if interaction.errors.empty?
            interaction.instance_variable_set(:@_interaction_result, result)
          else
            interaction.instance_variable_set(
              :@_interaction_runtime_errors, interaction.errors.dup)
          end
        end
      end
    end

    # @private
    def self.method_missing(*args, &block)
      super do |klass, names, options|
        raise InvalidFilterError, 'no name' if names.empty?

        names.each do |attribute|
          if attribute.to_s.start_with?('_interaction_')
            raise InvalidFilterError, attribute.inspect
          end

          filter = klass.new(attribute, options, &block)
          filters.add(filter)
          attr_accessor filter.name

          filter.default if filter.has_default?
        end
      end
    end

    private

    def input_errors
      Validation.validate(self.class.filters, inputs).each do |error|
        errors.add_sym(*error)
      end
    end

    def runtime_errors
      return unless instance_variable_defined?(:@_interaction_runtime_errors)

      @_interaction_runtime_errors.symbolic.each do |attribute, symbols|
        symbols.each { |symbol| errors.add_sym(attribute, symbol) }
      end

      @_interaction_runtime_errors.messages.each do |attribute, messages|
        messages.each { |message| errors.add(attribute, message) }
      end
    end
  end
end
