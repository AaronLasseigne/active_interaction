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
  #     integer :c, allow_nil: true
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

    extend OverloadHash

    validate do
      return unless @_interaction_errors
      @_interaction_errors.each do |attribute, message|
        errors.add(attribute, message)
      end
    end

    # @private
    def initialize(options = {})
      options = options.with_indifferent_access

      if options.has_key?(:result)
        raise ArgumentError, ':result is reserved and can not be used'
      end

      options.each do |attribute, value|
        method = "_filter__#{attribute}="
        if respond_to?(method, true)
          send(method, value)
        else
          instance_variable_set("@#{attribute}", value)
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
    # @raise [InteractionInvalid] if there are any errors on the model.
    #
    # @return The return value of {#execute}.
    def self.run!(options = {})
      outcome = run(options)
      if outcome.invalid?
        raise InteractionInvalid, outcome.errors.full_messages.join(', ')
      end
      outcome.result
    end

    # @private
    def self.method_missing(type, *args, &block)
      options = args.last.is_a?(Hash) ? args.pop : {}
      args.each do |attribute|
        filter = Filter.factory(type).new(attribute, options, &block)
        set_up_reader(filter)
        set_up_writer(filter)
        set_up_validator(filter)
      end
    end
    private_class_method :method_missing

    # @private
    def self.set_up_reader(filter)
      default = nil
      if filter.options.has_key?(:default)
        begin
          default = Caster.factory(filter.type).
            prepare(filter.name, filter.options[:default], filter.options, &filter.block)
        rescue InvalidNestedValue, InvalidValue
          raise InvalidDefaultValue
        end
      end

      define_method(filter.name) do
        symbol = "@#{filter.name}"
        if instance_variable_defined?(symbol)
          instance_variable_get(symbol)
        else
          default
        end
      end
    end
    private_class_method :set_up_reader

    # @private
    def self.set_up_writer(filter)
      attr_writer filter.name

      writer = "_filter__#{filter.name}="

      define_method(writer) do |value|
        value =
          begin
            Caster.factory(filter.type).
              prepare(filter.name, value, filter.options, &filter.block)
          rescue InvalidNestedValue, InvalidValue, MissingValue
            value
          end
        instance_variable_set("@#{filter.name}", value)
      end
      private writer
    end
    private_class_method :set_up_writer

    # @private
    def self.set_up_validator(filter)
      validator = "_validate__#{filter.name}__#{filter.type}"

      validate validator

      define_method(validator) do
        begin
          Caster.factory(filter.type).
            prepare(filter.name, send(filter.name), filter.options, &filter.block)
        rescue InvalidNestedValue
          errors.add(filter.name, :invalid_nested)
        rescue InvalidValue
          errors.add(filter.name, :invalid,
                     type: I18n.translate("#{i18n_scope}.types.#{filter.type.to_s}"))
        rescue MissingValue
          errors.add(filter.name, :missing)
        end
      end
      private validator
    end
    private_class_method :set_up_validator
  end
end
