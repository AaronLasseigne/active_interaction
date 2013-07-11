module ActiveInteraction
  # @private
  class FilterMethods
    include Enumerable
    include OverloadHash

    def self.evaluate(&block)
      me = new
      me.instance_eval(&block)
      me
    end

    def initialize
      @filter_methods = []
    end

    def each(&block)
      @filter_methods.each(&block)
    end

    def method_missing(filter_type, *args, &block)
      @filter_methods.push(FilterMethod.new(filter_type, *args, &block))
    end
    private :method_missing
  end
end
