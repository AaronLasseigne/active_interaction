module ActiveInteraction
  # Helper module for allowing the use of `hash` as both the built-in method
  #   and a part of a DSL.
  module OverloadHash
    def hash(*args, &block)
      if args.empty? && !block_given?
        super
      else
        method_missing(:hash, *args, &block)
      end
    end
  end
end
