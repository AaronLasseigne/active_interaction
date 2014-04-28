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
  # Execute code in a transaction. If ActiveRecord isn't available, don't do
  # anything special.
  module Transactable
    extend ActiveSupport::Concern

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
      def transaction(enable = true, options = {})
        @_interaction_transaction_enabled = enable
        @_interaction_transaction_options = options

        nil
      end

      def transaction?
        unless defined?(@_interaction_transaction_enabled)
          @_interaction_transaction_enabled = true
        end

        @_interaction_transaction_enabled
      end

      def transaction_options
        unless defined?(@_interaction_transaction_options)
          @_interaction_transaction_options = {}
        end

        @_interaction_transaction_options
      end
    end
  end
end
