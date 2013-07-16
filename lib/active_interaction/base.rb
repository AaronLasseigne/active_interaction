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

    extend OverloadHash

    # Returns the output from {#execute} if there are no validation errors or
    #   `nil` otherwise.
    #
    # @return [Nil] if there are validation errors.
    # @return [Object] if there are no validation errors.
    attr_reader :result

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
    #
    # @raise [NotImplementedError] if the method is not defined.
    def execute
      raise NotImplementedError
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
          interaction.instance_variable_set(:@result, result)
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
      raise InteractionInvalid if outcome.invalid?
      outcome.result
    end

    # @private
    def self.method_missing(type, *args, &block)
      filter = Filter.factory(type)
      options = args.last.is_a?(Hash) ? args.pop : {}
      args.each do |attribute|
        set_up_reader(attribute, filter, options, &block)
        set_up_writer(attribute, filter, options, &block)
        set_up_validator(attribute, type, filter, options, &block)
      end
    end
    private_class_method :method_missing

    # @private
    def self.set_up_reader(attribute, filter, options, &block)
      default = nil
      if options.has_key?(:default)
        begin
          default = filter.
            prepare(attribute, options.delete(:default), options, &block)
        rescue InvalidValue
          raise InvalidDefaultValue
        end
      end

      define_method(attribute) do
        symbol = "@#{attribute}"
        if instance_variable_defined?(symbol)
          instance_variable_get(symbol)
        else
          default
        end
      end
    end
    private_class_method :set_up_reader

    # @private
    def self.set_up_writer(attribute, filter, options, &block)
      attr_writer attribute

      writer = "_filter__#{attribute}="

      define_method(writer) do |value|
        value =
          begin
            filter.prepare(attribute, value, options, &block)
          rescue InvalidValue, MissingValue
            value
          end
        instance_variable_set("@#{attribute}", value)
      end
      private writer
    end
    private_class_method :set_up_writer

    # @private
    def self.set_up_validator(attribute, type, filter, options, &block)
      validator = "_validate__#{attribute}__#{type}"

      validate validator

      define_method(validator) do
        begin
          filter.prepare(attribute, send(attribute), options, &block)
        rescue MissingValue
          errors.add(attribute, 'is required')
        rescue InvalidValue
          errors.add(attribute,
                     "is not a valid #{type.to_s.humanize.downcase}")
        end
      end
      private validator
    end
    private_class_method :set_up_validator
  end
end
