module ActiveInteraction
  class HashFilter < FilterWithBlock
    def method_missing(type, *args, &block)
      options = args.last.is_a?(Hash) ? args.pop : {}

      args.each do |name|
        filters.add(Filter.factory(type).new(name, options.dup, &block))
      end
    end
    private :method_missing
  end
end
