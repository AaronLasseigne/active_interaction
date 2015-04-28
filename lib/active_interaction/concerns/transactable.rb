# coding: utf-8

begin
  require 'active_record'
rescue LoadError
  module ActiveRecord # rubocop:disable Documentation
    Rollback = Class.new(ActiveInteraction::Error)

    class Base # rubocop:disable Documentation
      def self.transaction(*)
        yield
      rescue Rollback
      end
    end
  end
end

module ActiveInteraction
  # @private
  #
  # Execute code in a transaction. If ActiveRecord isn't available, don't do
  # anything special.
  #
  # @since 1.2.0
  module Transactable
    extend ActiveSupport::Concern

    # @yield []
    def transaction
      return unless block_given?

      if self.class.transaction?
        ActiveRecord::Base.transaction(self.class.transaction_options) do
          yield
        end
      else
        yield
      end
    end

    module ClassMethods # rubocop:disable Documentation
      # @param klass [Class]
      def inherited(klass)
        klass.transaction_without_deprecation(
          transaction?, transaction_options.dup)

        super
      end

      # @param enable [Boolean]
      # @param options [Hash]
      #
      # @return [nil]
      def transaction(enable, options = {})
        @_interaction_transaction_enabled = enable
        @_interaction_transaction_options = options

        nil
      end
      ActiveInteraction.deprecate self, :transaction

      # @return [Boolean]
      def transaction?
        unless defined?(@_interaction_transaction_enabled)
          @_interaction_transaction_enabled = true
        end

        @_interaction_transaction_enabled
      end

      # @return [Hash]
      def transaction_options
        unless defined?(@_interaction_transaction_options)
          @_interaction_transaction_options = {}
        end

        @_interaction_transaction_options
      end
    end
  end
end
