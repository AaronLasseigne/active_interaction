# coding: utf-8

module ActiveInteraction
  # @abstract
  #
  # Common logic for filters that can guess the class they operator on based on
  #   their name.
  #
  # @private
  class AbstractFilter < Filter
    def initialize(*)
      super

      @klass = self.class.slug.to_s.camelize.constantize
    end

    private

    # @return [Class]
    def klass
      @klass
    end
  end
end
