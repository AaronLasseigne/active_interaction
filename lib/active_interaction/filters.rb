module ActiveInteraction
  # @private
  class Filters
    include Enumerable

    def initialize
      @filters = []
    end

    def each(&block)
      @filters.each(&block)
    end

    def add(filter)
      @filters << filter

      self
    end
  end
end
