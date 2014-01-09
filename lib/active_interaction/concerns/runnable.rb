# coding: utf-8

begin
  require 'active_record'
rescue LoadError
  module ActiveRecord
    class Base # rubocop:disable Documentation
      def self.transaction(*)
        yield
      end
    end
  end
end

module ActiveInteraction
  # @abstract Include and override {#execute} for a concrete class.
  #
  # @note Must be included after `ActiveModel::Validations`.
  #
  # Runs code in transactions and only provides the result if there are no
  #   validation errors.
  #
  # @since 1.0.0
  module Runnable
    extend ActiveSupport::Concern

    # @param (see Base#initialize)
    def initialize(*)
      @_interaction_errors = Errors.new(self)
      @_interaction_result = nil
      @_interaction_runtime_errors = nil
    end

    # @return [Errors]
    def errors
      @_interaction_errors
    end

    # @abstract
    #
    # @raise [NotImplementedError]
    def execute
      fail NotImplementedError
    end

    # @return [Object]
    # @return [nil]
    def result
      @_interaction_result
    end

    # @param result [Object]
    #
    # @return (see #result)
    def result=(result)
      if errors.empty?
        @_interaction_result = result
      else
        @_interaction_runtime_errors = errors.dup
      end
    end

    # @return [Boolean]
    def valid?(*)
      super || (@_interaction_result = nil)
    end

    private

    # @param other [Runnable]
    # @param (see #initialize)
    #
    # @return (see #result)
    #
    # @raise [Interrupt]
    def compose(other, *args)
      outcome = other.run(*args)

      if outcome.valid?
        outcome.result
      else
        fail Interrupt, outcome
      end
    end

    # @return (see #result)
    def run
      return unless valid?

      self.result = ActiveRecord::Base.transaction do
        begin
          execute
        rescue Interrupt => interrupt
          interrupt.outcome.errors.full_messages.each do |message|
            errors.add(:base, message) unless errors.added?(:base, message)
          end
        end
      end
    end

    module ClassMethods
      # @param (see Runnable#initialize)
      #
      # @return [Runnable]
      def run(*args)
        new(*args).tap { |instance| instance.send(:run) }
      end

      # @param (see #run)
      #
      # @return (see #result)
      #
      # @raise [InvalidInteractionError]
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
