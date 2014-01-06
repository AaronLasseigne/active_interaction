# coding: utf-8

module ActiveInteraction
  # @private
  class AbstractFilter < Filter
    private

    def klass
      self.class.slug.to_s.camelize.constantize
    end
  end
end
