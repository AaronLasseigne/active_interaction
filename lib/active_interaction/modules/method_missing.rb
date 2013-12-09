# coding: utf-8

module ActiveInteraction
  # @private
  module MethodMissing
    def method_missing(slug, *args, &block)
      begin
        klass = Filter.factory(slug)
      rescue MissingFilterError
        super
      end

      options = args.last.is_a?(Hash) ? args.pop : {}

      yield(klass, args, options) if block_given?

      self
    end
  end
end
