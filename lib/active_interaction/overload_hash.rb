module ActiveInteraction
  module OverloadHash
    def hash(*args, &block)
      if args.length == 0 && !block_given?
        super
      else
        method_missing(:hash, *args, &block)
      end
    end
  end
end
