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
  # @abstract Include and override {#execute} to implement a custom Runnable
  #   class.
  #
  # @note Must be included after `ActiveModel::Validations`.
  #
  # Runs code in transactions and only provides the result if there are no
  #   validation errors.
  #
  # @since 1.0.0
  module Runnable
    extend ActiveSupport::Concern
    include ::ActiveModel::Validations

    included do
      validate :runtime_errors
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
        @_interaction_runtime_errors = nil
      else
        @_interaction_result = nil
        @_interaction_runtime_errors = errors.dup
      end
    end

    # @return [Boolean]
    def valid?(*)
      super || (self.result = nil)
    end

    private

    # @param other [Class]
    # @param (see ClassMethods.run)
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

    # @return (see #result=)
    # @return [nil]
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

    # @return (see #result)
    #
    # @raise [InvalidInteractionError]
    def run!
      run

      if valid?
        result
      else
        fail InvalidInteractionError, errors.full_messages.join(', ')
      end
    end

    # @!group Validations

    def runtime_errors
      if @_interaction_runtime_errors
        errors.merge!(@_interaction_runtime_errors)
      end
    end

    module ClassMethods
      # @private
      def new(*)
        super.tap do |instance|
          {
            :@_interaction_errors => Errors.new(instance),
            :@_interaction_result => nil,
            :@_interaction_runtime_errors => nil
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
