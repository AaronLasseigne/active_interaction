module ActiveInteraction
  # Helper module for delegating missing methods to {Filter}s, effectively
  #   creating a DSL.
  #
  # @since 0.6.0
  module MethodMissing
    private

    def method_missing(slug, *args, &block)
      begin
        klass = Filter.factory(slug)
      rescue MissingFilter
        super
      end

      options = args.last.is_a?(Hash) ? args.pop : {}

      yield(klass, args, options) if block_given?
    end
  end
end
