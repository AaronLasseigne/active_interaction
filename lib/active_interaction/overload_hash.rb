module ActiveInteraction
  module OverloadHash
    def hash(*args, &block)
      if args.length == 0 && !block_given?
        super
      elsif block_given?
        method_missing(:hash, *args, &block)
      else
        method_missing(:hash, *args)
      end
    end
  end
end
