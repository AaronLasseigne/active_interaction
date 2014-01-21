# coding: utf-8

require 'active_support/core_ext/hash/indifferent_access'

module ActiveInteraction
  # @abstract Subclass and override {#execute} to implement a custom
  #   ActiveInteraction::Base class.
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
    include ActiveModelable
    include Runnable

    validate :input_errors

    class << self
      include Hashable
      include Missable

      # Get or set the description.
      #
      # @example
      #   core.desc
      #   # => nil
      #   core.desc('descriptive!')
      #   core.desc
      #   # => "descriptive!"
      #
      # @param desc [String, nil] what to set the description to
      #
      # @return [String, nil] the description
      #
      # @since 0.8.0
      def desc(desc = nil)
        if desc.nil?
          unless instance_variable_defined?(:@_interaction_desc)
            @_interaction_desc = nil
          end
        else
          @_interaction_desc = desc
        end

        @_interaction_desc
      end

      # Get all the filters defined on this interaction.
      #
      # @return [Hash{Symbol => Filter}]
      #
      # @since 0.6.0
      def filters
        @_interaction_filters ||= {}
      end

      # @private
      def method_missing(*args, &block)
        super do |klass, names, options|
          fail InvalidFilterError, 'missing attribute name' if names.empty?

          names.each { |name| add_filter(klass, name, options, &block) }
        end
      end

      # @!method run(*)
      #   Runs validations and if there are no errors it will call {#execute}.
      #
      #   @param (see ActiveInteraction::Base#initialize)
      #
      #   @return (see ActiveInteraction::Runnable::ClassMethods#run)
      loop

      # @!method run!(*)
      #   Like {.run} except that it returns the value of {#execute} or raises
      #     an exception if there were any validation errors.
      #
      #   @param (see ActiveInteraction::Base#initialize)
      #
      #   @return (see ActiveInteraction::Runnable::ClassMethods#run!)
      #
      #   @raise (see ActiveInteraction::Runnable::ClassMethods#run!)
      loop

      private

      def add_filter(klass, name, options, &block)
        fail InvalidFilterError, name.inspect if reserved?(name)

        filter = klass.new(name, options, &block)
        filters[name] = filter
        attr_accessor name
        define_method("#{name}?") { !public_send(name).nil? }

        # This isn't required, but it makes invalid defaults raise errors
        #   on class definition instead of on execution.
        filter.default if filter.default?
      end

      # @param klass [Class]
      # @param only [Array<Symbol>, nil]
      # @param except [Array<Symbol>, nil]
      #
      # @return (see .filters)
      def import(klass, only: nil, except: nil)
        other_filters = klass.filters.dup
        other_filters.select! { |k, _| only.include?(k) } if only
        other_filters.reject! { |k, _| except.include?(k) } if except

        filters.merge!(other_filters)
      end

      def inherited(klass)
        klass.instance_variable_set(:@_interaction_filters, filters.dup)
      end

      def reserved?(symbol)
        symbol.to_s.start_with?('_interaction_')
      end
    end

    # @param inputs [Hash{Symbol => Object}] Attribute values to set.
    #
    # @private
    def initialize(inputs = {})
      fail ArgumentError, 'inputs must be a hash' unless inputs.is_a?(Hash)

      process_inputs(inputs.symbolize_keys)
    end

    # @!method execute
    #   @abstract
    #
    #   Runs the business logic associated with the interaction. The method is
    #     only run when there are no validation errors. The return value is
    #     placed into {#result}. This method must be overridden in the
    #     subclass. This method is run in a transaction if ActiveRecord is
    #     available.
    #
    #   @raise (see ActiveInteraction::Runnable#execute)
    loop

    # Returns the inputs provided to {.run} or {.run!} after being cast based
    #   on the filters in the class.
    #
    # @return [Hash{Symbol => Object}] All inputs passed to {.run} or {.run!}.
    #
    # @since 0.6.0
    def inputs
      self.class.filters.keys.each_with_object({}) do |name, h|
        h[name] = public_send(name)
      end
    end

    private

    def process_inputs(inputs)
      inputs.each do |key, value|
        fail InvalidValueError, key.inspect if self.class.send(:reserved?, key)

        instance_variable_set("@#{key}", value)
      end

      self.class.filters.each do |name, filter|
        begin
          public_send("#{name}=", filter.clean(inputs[name]))
        rescue InvalidValueError, MissingValueError
          # Validators (#input_errors) will add errors if appropriate.
        end
      end
    end

    # @!group Validations

    def input_errors
      Validation.validate(self.class.filters, inputs).each do |error|
        errors.add_sym(*error)
      end
    end
  end
end
