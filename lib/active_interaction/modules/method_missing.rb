# coding: utf-8

module ActiveInteraction
  # @private
  module MethodMissing
    def respond_to?(slug, include_all = false)
      !!filter(slug) || super
    end

    def method_missing(slug, *args, &block)
      super unless (klass = filter(slug))

      options = args.last.is_a?(Hash) ? args.pop : {}

      yield(klass, args, options) if block_given?

      self
    end

    private

    def filter(slug)
      Filter.factory(slug)
    rescue MissingFilterError
      nil
    end
  end
end
