module ActiveInteraction
  class AttrBlock
    include Enumerable

    def self.evaluate(&block)
      me = new
      me.instance_eval(&block)
      me
    end

    def initialize
      @attr_requirements = []
    end

    def each(&block)
      @attr_requirements.each(&block)
    end

    def method_missing(attr_type, *args, &block)
      @attr_requirements.push([attr_type, args, block])
    end
    private :method_missing
  end
end
