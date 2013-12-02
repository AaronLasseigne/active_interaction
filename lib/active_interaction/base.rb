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

    # @param options [Hash{Symbol => Object}] Attribute values to set.
    #
    # @private
    def initialize(options = {})
      @_interaction_errors = Errors.new(self)
      @_interaction_result = nil
      @_interaction_runtime_errors = nil

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
          # Validators (#input_errors) will add errors if appropriate.
        end
      end
    end

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
      @_interaction_result
    end

    # @private
    def errors
      @_interaction_errors
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
          result = transaction do
            begin
              interaction.execute
            rescue Interrupt
              # Inner interaction failed. #interact handles merging errors.
            end
          end

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
        raise InvalidFilterError, 'missing attribute name' if names.empty?

        names.each do |attribute|
          if attribute.to_s.start_with?('_interaction_')
            raise InvalidFilterError, attribute.inspect
          end

          filter = klass.new(attribute, options, &block)
          filters.add(filter)
          attr_accessor filter.name

          # This isn't required, but it makes invalid defaults raise errors on
          #   class definition instead of on execution.
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
      if @_interaction_runtime_errors
        errors.merge!(@_interaction_runtime_errors)
      end
    end

    def interact(interaction, options = {})
      outcome = interaction.run(options)
      return outcome.result if outcome.valid?

      # This can't use Errors#merge! because the errors have to be added to
      # base.
      outcome.errors.messages.values.flatten.each do |message|
        errors.add(:base, message) unless errors.added?(:base, message)
      end

      raise Interrupt
    end
  end
end
