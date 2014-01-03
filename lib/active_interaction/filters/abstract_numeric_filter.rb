# coding: utf-8

module ActiveInteraction
  # @private
  class AbstractNumericFilter < Filter
    def cast(value)
      case value
      when klass
        value
      when Numeric, String
        begin
          send(klass.name, value)
        rescue ArgumentError
          super
        end
      else
        super
      end
    end

    private

    def klass
      self.class.slug.to_s.camelize.constantize
    end
  end
end
