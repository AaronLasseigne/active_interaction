# coding: utf-8

module ActiveInteraction
  # A collection of {Filter}s.
  #
  # @since 0.6.0
  class Filters
    include Enumerable

    def initialize
      @filters = []
    end

    # @return [Enumerator]
    def each(&block)
      @filters.each(&block)
    end

    # @param filter [Filter]
    #
    # @return [Filters]
    def add(filter)
      if @filters.any? { |f| f.name == filter.name }
        fail InvalidFilterError, "#{filter.name}: duplicate name"
      end

      @filters << filter

      self
    end
  end
end
