# frozen_string_literal: true

module ActiveInteraction
  # @abstract Subclass and override {#execute} to implement a custom
  #   ActiveInteraction::Base class.
  #
  # Provides interaction functionality. Subclass this to create an interaction.
  #
  # @example
  #   class ExampleInteraction < ActiveInteraction::Base
  #     # Required
  #     boolean :a
  #
  #     # Optional
  #     boolean :b, default: false
  #
  #     def execute
  #       a && b
  #     end
  #   end
  #
  #   outcome = ExampleInteraction.run(a: true)
  #   if outcome.valid?
  #     outcome.result
  #   else
  #     outcome.errors
  #   end
  class Base
    include ActiveModelable
    include ActiveRecordable
    include Runnable

    define_callbacks :filter

    class << self
      include Hashable
      include Missable

      # @!method run(inputs = {})
      #   @note If the interaction inputs are valid and there are no runtime
      #     errors and execution completed successfully, {#valid?} will always
      #     return true.
      #
      #   Runs validations and if there are no errors it will call {#execute}.
      #
      #   @param input [Hash, ActionController::Parameters]
      #
      #   @return [Base]

      # @!method run!(inputs = {})
      #   Like {.run} except that it returns the value of {#execute} or raises
      #     an exception if there were any validation errors.
      #
      #   @param (see ActiveInteraction::Base.run)
      #
      #   @return (see ActiveInteraction::Runnable::ClassMethods#run!)
      #
      #   @raise (see ActiveInteraction::Runnable::ClassMethods#run!)

      # Get or set the description.
      #
      # @example
      #   core.desc
      #   # => nil
      #   core.desc('Description!')
      #   core.desc
      #   # => "Description!"
      #
      # @param desc [String, nil] What to set the description to.
      #
      # @return [String, nil] The description.
      def desc(desc = nil)
        if desc.nil?
          @_interaction_desc = nil unless instance_variable_defined?(:@_interaction_desc)
        else
          @_interaction_desc = desc
        end

        @_interaction_desc
      end

      # Get all the filters defined on this interaction.
      #
      # @return [Hash{Symbol => Filter}]
      def filters
        # rubocop:disable Naming/MemoizedInstanceVariableName
        @_interaction_filters ||= {}
        # rubocop:enable Naming/MemoizedInstanceVariableName
      end

      private

      # rubocop:disable Style/MissingRespondToMissing
      def method_missing(*args, &block)
        super do |klass, names, options|
          raise InvalidFilterError, 'missing attribute name' if names.empty?

          names.each { |name| add_filter(klass, name, options, &block) }
        end
      end
      # rubocop:enable Style/MissingRespondToMissing

      # @param klass [Class]
      # @param name [Symbol]
      # @param options [Hash]
      def add_filter(klass, name, options, &block)
        raise InvalidFilterError, %("#{name}" is a reserved name) if Inputs.reserved?(name)

        initialize_filter(klass.new(name, options, &block))
      end

      # Import filters from another interaction.
      #
      # @param klass [Class] The other interaction.
      # @param options [Hash]
      #
      # @option options [Array<Symbol>, nil] :only Import only these filters.
      # @option options [Array<Symbol>, nil] :except Import all filters except
      #   for these.
      #
      # @return (see .filters)
      #
      # @!visibility public
      def import_filters(klass, options = {})
        only = options[:only]
        except = options[:except]

        other_filters = klass.filters.dup
        other_filters.select! { |k, _| [*only].include?(k) } if only
        other_filters.reject! { |k, _| [*except].include?(k) } if except

        other_filters.each_value { |filter| initialize_filter(filter) }
      end

      # @param klass [Class]
      def inherited(klass)
        klass.instance_variable_set(:@_interaction_filters, filters.dup)

        super
      end

      # @param filter [Filter]
      def initialize_filter(filter)
        attribute = filter.name
        warn "WARNING: Redefining #{name}##{attribute} filter" if filters.key?(attribute)
        filters[attribute] = filter

        attr_accessor attribute

        eagerly_evaluate_default(filter)
      end

      # @param filter [Filter]
      def eagerly_evaluate_default(filter)
        default = filter.options[:default]
        filter.default if default && !default.is_a?(Proc)
      end
    end

    # @private
    def initialize(inputs = {})
      @_interaction_raw_inputs = inputs

      @_interaction_inputs = Inputs.new(inputs, self) do |name, input|
        public_send("#{name}=", input.value)
      end
    end

    # @!method compose(other, inputs = {})
    #   Run another interaction and return its result. If the other interaction
    #     fails, halt execution.
    #
    #   @param other (see ActiveInteraction::Runnable#compose)
    #   @param inputs (see ActiveInteraction::Base#initialize)
    #
    #   @return (see ActiveInteraction::Base.run!)

    # @!method execute
    #   @abstract
    #
    #   Runs the business logic associated with the interaction. This method is
    #   only run when there are no validation errors. The return value is
    #   placed into {#result}.
    #
    #   @raise (see ActiveInteraction::Runnable#execute)

    # Returns the inputs provided to {.run} or {.run!} after being cast based
    #   on the filters in the class.
    #
    # @return [Inputs] All expected inputs passed to {.run} or {.run!}.
    def inputs
      @_interaction_inputs
    end

    # @private
    def read_attribute_for_validation(attribute)
      super(errors.deindex_attribute(attribute))
    end

    protected

    def run_validations!
      filter

      super if errors.empty?
    end

    private

    def filter
      run_callbacks(:filter) do
        Validation.validate(self, self.class.filters, inputs).each do |attr, type, kwargs = {}|
          errors.add(attr, type, **kwargs)
        end
      end
    end
  end
end
