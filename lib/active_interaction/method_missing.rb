module ActiveInteraction
  module MethodMissing
    def method_missing(*args, &block)
      begin
        klass = Filter.factory(args.first)
      rescue MissingFilter
        super
      end

      args.shift
      options = args.last.is_a?(Hash) ? args.pop : {}

      yield(klass, args, options) if block_given?
    end
  end
end
