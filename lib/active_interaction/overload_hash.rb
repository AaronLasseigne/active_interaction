module ActiveInteraction
  # @private
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
