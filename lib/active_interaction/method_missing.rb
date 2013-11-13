module ActiveInteraction
  module MethodMissing
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
