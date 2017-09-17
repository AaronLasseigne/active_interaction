# frozen_string_literal: true

module ActiveInteraction
  # @abstract
  #
  # Common logic for filters that can guess the class they operator on based on
  #   their name.
  #
  # @private
  class AbstractFilter < Filter
    private

    # @return [Class]
    def klass
      @klass ||= Object.const_get(self.class.slug.to_s.camelize, false)
    end
  end
end
