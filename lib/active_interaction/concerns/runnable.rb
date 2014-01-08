# coding: utf-8

begin
  require 'active_record'
rescue LoadError
  module ActiveRecord
    class Base # rubocop:disable Documentation
      def self.transaction(*_)
        yield
      end
    end
  end
end

module ActiveInteraction
  # TODO
  module Runnable
    extend ActiveSupport::Concern

    def initialize(*_)
      @_interaction_errors = Errors.new(self)
      @_interaction_result = nil
      @_interaction_runtime_errors = nil
    end

    # @private
    def errors
      @_interaction_errors
    end

    # Runs the business logic associated with the interaction. The method is
    #   only run when there are no validation errors. The return value is
    #   placed into {#result}. This method must be overridden in the subclass.
    #   This method is run in a transaction if ActiveRecord is available.
    #
    # @raise [NotImplementedError] if the method is not defined.
    #
    # @abstract
    def execute
      fail NotImplementedError
    end

    # Returns the output from {#execute} if there are no validation errors or
    #   `nil` otherwise.
    #
    # @return [Object, nil] the output or nil if there were validation errors
    def result
      @_interaction_result
    end

    # @private
    def result=(result)
      if errors.empty?
        @_interaction_result = result
      else
        @_interaction_runtime_errors = errors.dup
      end
    end

    # @private
    def valid?(*_)
      super || (@_interaction_result = nil)
    end

    module ClassMethods # rubocop:disable Documentation
      # Runs validations and if there are no errors it will call {#execute}.
      #
      # @param (see #initialize)
      #
      # @return [ActiveInteraction::Base] An instance of the class `run` is
      #   called on.
      def run(*args)
        new(*args).tap do |instance|
          next unless instance.valid?

          instance.result = ActiveRecord::Base.transaction do
            begin
              instance.execute
            rescue Interrupt
            end
          end
        end
      end

      # Like {.run} except that it returns the value of {#execute} or raises an
      #   exception if there were any validation errors.
      #
      # @param (see .run)
      #
      # @return [Object] the return value of {#execute}
      #
      # @raise [InvalidInteractionError] if the outcome is invalid
      def run!(*args)
        outcome = run(*args)

        if outcome.valid?
          outcome.result
        else
          fail InvalidInteractionError, outcome.errors.full_messages.join(', ')
        end
      end
    end
  end
end
