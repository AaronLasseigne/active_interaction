module ActiveInteraction
  # @private
  class AttrMethods
    include Enumerable

    def self.evaluate(&block)
      me = new
      me.instance_eval(&block)
      me
    end

    def initialize
      @attr_methods = []
    end

    def each(&block)
      @attr_methods.each(&block)
    end

    def method_missing(attr_type, *args, &block)
      @attr_methods.push(AttrMethod.new(attr_type, *args, &block))
    end
    private :method_missing
  end
end
