# frozen_string_literal: true

module ActiveInteraction
  # Handle common `method_missing` functionality.
  #
  # @private
  module Missable
    extend ActiveSupport::Concern

    # @param slug [Symbol]
    #
    # @yield [klass, args, options]
    #
    # @yieldparam klass [Class]
    # @yieldparam args [Array]
    # @yieldparam options [Hash]
    #
    # @return [Missable]
    def method_missing(slug, *args)
      return super unless (klass = filter(slug))

      options = args.last.is_a?(Hash) ? args.pop : {}

      yield(klass, args, options) if block_given?

      self
    end

    private

    # @param slug [Symbol]
    #
    # @return [Filter, nil]
    def filter(slug)
      Filter.factory(slug)
    rescue MissingFilterError
      nil
    end

    # @param slug [Symbol]
    #
    # @return [Boolean]
    def respond_to_missing?(slug, *)
      filter(slug)
    end
  end
end
