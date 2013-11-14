require 'active_support/core_ext/hash/indifferent_access'

begin
  require 'active_record'
rescue LoadError
end

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
    extend ::ActiveModel::Naming
    include ::ActiveModel::Conversion
    include ::ActiveModel::Validations

    # @private
    def new_record?
      true
    end

    # @private
    def persisted?
      false
    end

    # @private
    def self.i18n_scope
      :active_interaction
    end

    # @private
    def i18n_scope
      self.class.i18n_scope
    end

    extend MethodMissing
    extend OverloadHash

    validate do
      Validation.validate(self.class.filters, inputs).each do |error|
        errors.add_sym(*error)
      end
    end

    validate do
      return unless @_interaction_errors

      @_interaction_errors.symbolic.each do |attribute, symbols|
        symbols.each { |symbol| errors.add_sym(attribute, symbol) }
      end

      @_interaction_errors.messages.each do |attribute, messages|
        messages.each { |message| errors.add(attribute, message) }
      end
    end

    # Returns the inputs provided to {.run} or {.run!} after being cast based
    #   on the filters in the class.
    #
    # @return [Hash] All inputs passed to {.run} or {.run!}.
    # @since 0.6.0
    def inputs
      self.class.filters.reduce({}) do |h, filter|
        h[filter.name] = send(filter.name)
        h
      end
    end

    # @private
    def initialize(options = {})
      options = options.symbolize_keys

      options.each do |key, value|
        instance_variable_set("@#{key}", value)
      end

      self.class.filters.each do |filter|
        begin
          send("#{filter.name}=", filter.clean(options[filter.name]))
        rescue InvalidValue, MissingValue
        end
      end
    end

    # Runs the business logic associated with the interaction. The method is
    #   only run when there are no validation errors. The return value is
    #   placed into {#result}. This method must be overridden in the subclass.
    #   This method is run in a transaction if ActiveRecord is available.
    #
    # @raise [NotImplementedError] if the method is not defined.
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
      @errors ||= Errors.new(self)
    end

    # @private
    def valid?(*args)
      super || instance_variable_set(:@_interaction_result, nil)
    end

    # @private
    def self.transaction
      return unless block_given?

      if defined?(ActiveRecord)
        ::ActiveRecord::Base.transaction { yield }
      else
        yield
      end
    end
    private_class_method :transaction

    # @private
    def self.filters
      @filters ||= Filters.new
    end

    # @!macro [new] run_attributes
    #   @param options [Hash] Attribute values to set.

    # Runs validations and if there are no errors it will call {#execute}.
    #
    # @macro run_attributes
    #
    # @return [ActiveInteraction::Base] An instance of the class `run` is
    #   called on.
    def self.run(options = {})
      new(options).tap do |interaction|
        if interaction.valid?
          result = transaction { interaction.execute }

          if interaction.errors.empty?
            interaction.instance_variable_set(:@_interaction_result, result)
          else
            interaction.instance_variable_set(:@_interaction_errors,
              interaction.errors.dup)
          end
        end
      end
    end

    # Like {.run} except that it returns the value of {#execute} or raises an
    #   exception if there were any validation errors.
    #
    # @macro run_attributes
    #
    # @raise [InteractionInvalidError] if there are any errors on the model.
    #
    # @return The return value of {#execute}.
    def self.run!(options = {})
      outcome = run(options)
      if outcome.invalid?
        raise InteractionInvalidError, outcome.errors.full_messages.join(', ')
      end
      outcome.result
    end

    # @private
    def self.method_missing(*args, &block)
      super do |klass, names, options|
        raise InvalidFilterError, 'no name' if names.empty?

        names.each do |attribute|
          filter = klass.new(attribute, options, &block)
          filters.add(filter)
          attr_accessor filter.name
          filter.default if filter.has_default?
        end
      end
    end
  end
end
