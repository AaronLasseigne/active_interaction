# coding: utf-8

module ActiveInteraction
  # @abstract
  #
  # Common logic for filters that can guess the class they operator on based on
  #   their name.
  #
  # @private
  class AbstractFilter < Filter
    # @return [Class]
    attr_reader :klass
    private :klass

    def initialize(*)
      super

      @klass ||= self.class.slug.to_s.camelize.constantize
    end
  end
end
