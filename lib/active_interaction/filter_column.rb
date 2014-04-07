# coding: utf-8

module ActiveInteraction
  #
  class FilterColumn
    attr_reader :limit, :type

    class << self
      def intern(type)
        @columns ||= {}

        if @columns[type]
          @columns.fetch(type)
        else
          @columns[type] = new(type)
        end
      end

      private :new
    end

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
