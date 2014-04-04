# coding: utf-8

module ActiveInteraction
  #
  class FilterColumn
    attr_reader :limit, :type

    def initialize(type)
      @type = type
    end

    def number?
      [:integer, :float].include?(type)
    end

    def text?
      type == :string
    end
  end
end
