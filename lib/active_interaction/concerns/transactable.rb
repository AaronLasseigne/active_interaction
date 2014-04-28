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

    def transaction(options = {}, &block)
      ActiveRecord::Base.transaction(options, &block)
    end
  end
end
