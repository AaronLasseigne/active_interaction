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

    # @param name [Symbol] A filter name.
    #
    # @return [Link]
    def link(name)
      Link.new(name, inputs[name])
    end

    # @param *names [Symbol] A list of filter names.
    #
    # @return [Hash]
    def autolink(*names)
      names.each_with_object({}) do |name, mapping|
        mapping[name] = link(name)
      end
    end

    # @param *names [Symbol] A list of filter names.
    #
    # @return [Hash]
    def automove(*names)
      names.each_with_object({}) do |name, mapping|
        mapping[name] = name
      end
    end

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

    # @return (see #result=)
    # @return [nil]
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
