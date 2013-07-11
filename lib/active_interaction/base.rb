require 'active_support/core_ext/hash/indifferent_access'

module ActiveInteraction
  # @abstract Subclass and override {#execute} to implement
  #   a custom ActiveInteraction class.
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
    extend  ::ActiveModel::Naming
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
        if respond_to?("#{attribute}=")
          send("#{attribute}=", value)
        else
          instance_variable_set("@#{attribute}", value)
        end
      end
    end

    # Runs the business logic associated with the interactor. The method is only
    #   run when there are no validation errors. The return value is placed into
    #   {#result}. This method must be overridden in the subclass.
    #
    # @raise [NotImplementedError] if the method is not defined.
    def execute
      raise NotImplementedError
    end

    # @!macro [new] run_attributes
    #   @param options [Hash] Attribute values to set.
    #   @return [ActiveInteraction::Base] An instance of the class `$0` is called on.

    # Runs validations and if there are no errors it will call {#execute}.
    #
    # @macro run_attributes
    def self.run(options = {})
      me = new(options)

      me.instance_variable_set(:@result, me.execute) if me.valid?

      me
    end

    # Same as {.run} except that an exception is raised if there are any validation
    #   errors.
    #
    # @macro run_attributes
    # @raise [InteractionInvalid] if there are any errors on the model.
    def self.run!(options = {})
      outcome = run(options)
      raise InteractionInvalid if outcome.invalid?
      outcome
    end

    # @private
    def self.method_missing(filter_type, *args, &block)
      klass = Filter.factory(filter_type)
      options = args.last.is_a?(Hash) ? args.pop : {}
      args.each do |attribute|
        set_up_validator(attribute, filter_type, klass, options, &block)
      end
    end
    private_class_method :method_missing

    # @private
    def self.set_up_validator(attribute, type, filter, options, &block)
      validator = "_validate__#{attribute}__#{type}"

      attr_accessor attribute

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
