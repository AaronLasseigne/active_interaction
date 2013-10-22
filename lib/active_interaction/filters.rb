module ActiveInteraction
  # @private
  class Filters
    include Enumerable
    include OverloadHash

    def self.evaluate(&block)
      me = new
      me.instance_eval(&block)
      me
    end

    def initialize
      @filters = []
    end

    def each(&block)
      @filters.each(&block)
    end

    def method_missing(type, *args, &block)
      options = args.last.is_a?(Hash) ? args.pop : {}
      args = [:unnamed] if args.empty?
      args.each do |attribute|
        @filters.push(Filter.factory(type).new(attribute, options, &block))
      end
    end
    private :method_missing
  end
end
