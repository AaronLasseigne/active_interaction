# frozen_string_literal: true

module ActiveInteraction
  # @abstract Include and override {#execute} to implement a custom Runnable
  #   class.
  #
  # @note Must be included after `ActiveModel::Validations`.
  #
  # Runs code and provides the result.
  #
  # @private
  module Runnable
    # Used in #compose calls to link an attributes value and errors to an
    #   input in the composed interaction.
    #
    # @private
    class Link
      attr_reader :attribute, :value

      def initialize(attribute, value)
        @attribute = attribute
        @value = value
      end
    end

    extend ActiveSupport::Concern
    include ActiveModel::Validations

    included do
      define_callbacks :execute
    end

    # @return [Errors]
    def errors
      @_interaction_errors
    end

    # @abstract
    #
    # Runs the business logic associated with the interaction. This method is
    #   only run when there are no validation errors. The return value is
    #   placed into {#result}.
    #
    # @raise [NotImplementedError]
    def execute
      raise NotImplementedError
    end

    # @return [Object] If there are no validation errors.
    # @return [nil] If there are validation errors.
    def result
      @_interaction_result
    end

    # @param result [Object]
    #
    # @return (see #result)
    def result=(result)
      @_interaction_result = result
      @_interaction_valid = errors.empty?
    end

    # @return [Boolean]
    def valid?(*)
      if instance_variable_defined?(:@_interaction_valid)
        return @_interaction_valid
      end

      super
    end

    private

    # Used when sending inputs to `compose`. Links a filter in the current
    #   interaction such that its value is passed to the other interaction
    #   in the inputs and errors on that input are mapped back to the linked
    #   filter.
    #
    # @param name [Symbol] A filter name.
    #
    # @return [Link]
    def link(name)
      Link.new(name, inputs[name])
    end

    # Used when sending inputs to `compose`. Automatically creates a hash of
    #   links where the current interaction and the composed interaction share
    #   filter names.
    #
    # @param *names [Symbol] A list of filter names.
    # @param group [Symbol] Include filters from this group.
    #
    # @return [Hash{Symbol => Link}]
    def autolink(*names, group: nil)
      names += inputs.group(group).keys unless group.nil?

      names.each_with_object({}) do |name, mapping|
        mapping[name] = link(name)
      end
    end

    # Used with `merge!` to generate a hash of moves when the moved errors
    #   share the same name as where they're being moved to.
    #
    # @param *names [Symbol] A list of filter names.
    #
    # @return [Hash]
    def automove(*names)
      names.each_with_object({}) do |name, mapping|
        mapping[name] = name
      end
    end

    # Run another interaction and return its result. If the other interaction
    #   fails, halt execution.
    #
    # @param other [Class] The other interaction.
    # @param (see ClassMethods.run)
    #
    # @return (see #result)
    #
    # @raise [Interrupt]
    def compose(other, *args)
      outcome = other.run(*promote_values_from_links(args))

      if outcome.invalid?
        raise Interrupt.new(outcome.errors, extract_moves(args))
      end

      outcome.result
    end

    # @private
    def promote_values_from_links(args)
      args.map do |arg|
        next arg unless arg.respond_to?(:to_hash)

        arg.to_hash.each_with_object({}) do |(k, v), h|
          h[k] = v.is_a?(Link) ? v.value : v
        end
      end
    end

    # @private
    def extract_moves(args)
      args.each_with_object({}) do |arg, h|
        next arg unless arg.respond_to?(:to_hash)

        arg.to_hash.each do |k, v|
          next unless v.is_a?(Link)

          h[k] = v.attribute
        end
      end
    end

    # Runs validations and if there are no errors it will call {#execute}.
    #
    # @param (see ActiveInteraction::Base#initialize)
    #
    # @return [ActiveInteraction::Base]
    def run
      self.result =
        if valid?
          result, interrupt_errors, moves = run_callbacks(:execute) do
            begin
              [execute, nil, nil]
            rescue Interrupt => interrupt
              [nil, interrupt.errors, interrupt.moves]
            end
          end

          errors.merge!(interrupt_errors, move: moves) if interrupt_errors

          result
        end
    end

    # Like {.run} except that it returns the value of {#execute} or raises
    #   an exception if there were any validation errors.
    #
    # @param (see .run)
    #
    # @return [Object]
    #
    # @raise [InvalidInteractionError] If there are validation errors.
    def run!
      run

      unless valid?
        raise InvalidInteractionError, errors.full_messages.join(', ')
      end

      result
    end

    #
    module ClassMethods
      def new(*)
        super.tap do |instance|
          {
            :@_interaction_errors => Errors.new(instance),
            :@_interaction_result => nil
          }.each do |symbol, obj|
            instance.instance_variable_set(symbol, obj)
          end
        end
      end

      # @param (see Runnable#initialize)
      #
      # @return [Runnable]
      def run(*args)
        new(*args).tap { |instance| instance.send(:run) }
      end

      # @param (see Runnable#initialize)
      #
      # @return (see Runnable#run!)
      #
      # @raise (see Runnable#run!)
      def run!(*args)
        new(*args).send(:run!)
      end
    end
  end
end
