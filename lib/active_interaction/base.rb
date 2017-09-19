# frozen_string_literal: true

require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/inflector'

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
  class Base # rubocop:disable Metrics/ClassLength
    include ActiveModelable
    include ActiveRecordable
    include Runnable

    define_callbacks :type_check

    class << self
      include Hashable
      include Missable

      # @!method run(inputs = {})
      #   (see ActiveInteraction::Runnable#run)

      # @!method run!(inputs = {})
      #   (see ActiveInteraction::Runnable#run!)

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
      def filters
        @_interaction_filters ||= {}
      end

      # @private
      def method_missing(*args, &block) # rubocop:disable Style/MethodMissing
        super do |klass, names, options|
          raise InvalidFilterError, 'missing attribute name' if names.empty?

          names.each { |name| add_filter(klass, name, options, &block) }
        end
      end

      private

      # @param klass [Class]
      # @param name [Symbol]
      # @param options [Hash]
      def add_filter(klass, name, options, &block)
        if ActiveInteraction::Inputs.reserved?(name)
          raise InvalidFilterError, %("#{name}" is a reserved name)
        end

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
      # @option options [Array<Object>] :groups Add the filters to these
      #   groups. Defaults to the class name of the other interaction
      #   underscored. (e.g. `AdminUser` -> `:admin_user`)
      #
      # @return (see .filters)
      #
      # @!visibility public
      def import_filters(klass, options = {}) # rubocop:disable Metrics/AbcSize
        only = options[:only]
        except = options[:except]
        groups = options[:groups] || [klass.to_s.demodulize.underscore.to_sym]

        klass.filters.each do |name, filter|
          next if only && ![*only].include?(name)
          next if except && [*except].include?(name)

          options = filter.options.merge(groups: groups)
          add_filter(filter.class, name, options, &filter.block)
        end
      end

      # @param klass [Class]
      def inherited(klass)
        klass.instance_variable_set(:@_interaction_filters, filters.dup)

        super
      end

      # @param filter [Filter]
      def initialize_filter(filter)
        attribute = filter.name
        if filters.key?(attribute)
          warn "WARNING: Redefining #{name}##{attribute} filter"
        end
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

    # @param inputs [Hash{Symbol => Object}] Attribute values to set.
    #
    # @private
    def initialize(inputs = {})
      inputs = normalize_inputs!(inputs)
      process_inputs(inputs.symbolize_keys)
    end

    # @!method compose(other, inputs = {})
    #   (see ActiveInteraction::Runnable#compose)

    # @!method link(name)
    #   (see ActiveInteraction::Runnable#link)

    # @!method autolink(*names, group: nil)
    #   (see ActiveInteraction::Runnable#autolink)

    # @!method automove(*names)
    #   (see ActiveInteraction::Runnable#automove)

    # @!method execute
    #   (see ActiveInteraction::Runnable#execute)

    # Returns the inputs provided to {.run} or {.run!} after being cast based
    #   on the filters in the class.
    #
    # @return [Hash{Symbol => Object}] All inputs passed to {.run} or {.run!}.
    def inputs
      @inputs ||= self.class.filters
        .each_with_object(ActiveInteraction::Inputs.new) do |(name, filter), i|
          i.store(name, public_send(name), filter.groups)
        end
        .freeze
    end

    # Returns `true` if the given key was in the hash passed to {.run}.
    # Otherwise returns `false`. Use this to figure out if an input was given,
    # even if it was `nil`. Keys within nested hash filter can also be checked
    # by passing them in series.
    #
    # @example
    #   class Example < ActiveInteraction::Base
    #     integer :x, default: nil
    #     def execute; given?(:x) end
    #   end
    #   Example.run!()        # => false
    #   Example.run!(x: nil)  # => true
    #   Example.run!(x: rand) # => true
    #
    # @example Nested checks
    #   class Example < ActiveInteraction::Base
    #     hash :x, default: {} do
    #       integer :y, default: nil
    #     end
    #     def execute; given?(:x, :y) end
    #   end
    #   Example.run!()               # => false
    #   Example.run!(x: nil)         # => false
    #   Example.run!(x: {})          # => false
    #   Example.run!(x: { y: nil })  # => true
    #   Example.run!(x: { y: rand }) # => true
    #
    # @param input [#to_sym]
    #
    # @return [Boolean]
    def given?(input, *rest) # rubocop:disable Metrics/CyclomaticComplexity
      filter_level = self.class
      input_level = @_interaction_inputs

      [input, *rest].map(&:to_sym).each do |key|
        filter_level = filter_level.filters[key]

        break false if filter_level.nil? || input_level.nil?
        break false unless input_level.key?(key) || input_level.key?(key.to_s)

        input_level = input_level[key] || input_level[key.to_s]
      end && true
    end

    protected

    def run_validations!
      type_check

      super if errors.empty?
    end

    private

    # We want to allow both `Hash` objects and `ActionController::Parameters`
    # objects. In Rails < 5, parameters are a subclass of hash and calling
    # `#symbolize_keys` returns the entire hash, not just permitted values. In
    # Rails >= 5, parameters are not a subclass of hash but calling
    # `#to_unsafe_h` returns the entire hash.
    def normalize_inputs!(inputs)
      return inputs if inputs.is_a?(Hash)

      parameters = 'ActionController::Parameters'
      klass = parameters.safe_constantize
      return inputs.to_unsafe_h if klass && inputs.is_a?(klass)

      raise ArgumentError, "inputs must be a hash or #{parameters}"
    end

    # @param inputs [Hash{Symbol => Object}]
    def process_inputs(inputs)
      @_interaction_inputs = inputs

      inputs.each do |key, value|
        next if ActiveInteraction::Inputs.reserved?(key)

        populate_reader(key, value)
      end

      populate_filters(ActiveInteraction::Inputs.process(inputs))
    end

    def populate_reader(key, value)
      instance_variable_set("@#{key}", value) if respond_to?(key)
    end

    def populate_filters(inputs)
      self.class.filters.each do |name, filter|
        begin
          public_send("#{name}=", filter.clean(inputs[name], self))
        rescue InvalidValueError, MissingValueError, NoDefaultError
          nil # #type_check will add errors if appropriate.
        end
      end
    end

    def type_check
      run_callbacks(:type_check) do
        Validation.validate(self, self.class.filters, inputs).each do |error|
          errors.add(*error)
        end
      end
    end
  end
end
