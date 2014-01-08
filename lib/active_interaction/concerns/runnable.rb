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
    def initialize(*_)
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
    def valid?(*_)
      super || (@_interaction_result = nil)
    end

    module ClassMethods
      # @param (see Runnable#initialize)
      #
      # @return [Runnable]
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
