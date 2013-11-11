module ActiveInteraction
  # @private
  class FilterWithBlock < Filter
    include OverloadHash

    def initialize(name, options = {}, &block)
      super

      instance_eval(&block) if block_given?
    end

    def filters
      @filters ||= Filters.new
    end
  end
end
