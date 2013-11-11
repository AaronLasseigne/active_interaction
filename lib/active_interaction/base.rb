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
    extend Core
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

      @_interaction_errors.symbolic.each do |attribute, symbols|
        symbols.each { |symbol| errors.add_sym(attribute, symbol) }
      end

      @_interaction_errors.messages.each do |attribute, messages|
        messages.each { |message| errors.add(attribute, message) }
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
    def errors
      @errors ||= Errors.new(self)
    end

    # @private
    def valid?(*args)
      super || instance_variable_set(:@_interaction_result, nil)
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
            prepare(attribute, options[:default], options, &block)
        rescue InvalidNestedValue, InvalidValue
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
          rescue InvalidNestedValue, InvalidValue, MissingValue
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
        rescue InvalidNestedValue
          errors.add_sym(attribute, :invalid_nested)
        rescue InvalidValue
          errors.add_sym(attribute, :invalid, nil,
                     type: I18n.translate("#{i18n_scope}.types.#{type.to_s}"))
        rescue MissingValue
          errors.add_sym(attribute, :missing)
        end
      end
      private validator
    end
    private_class_method :set_up_validator
  end
end
