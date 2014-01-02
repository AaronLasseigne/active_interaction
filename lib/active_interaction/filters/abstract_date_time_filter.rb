# coding: utf-8

module ActiveInteraction
  # @private
  class AbstractDateTimeFilter < Filter
    def cast(value)
      case value
      when *klasses
        value
      when String
        begin
          if format?
            klass.strptime(value, format)
          else
            klass.parse(value)
          end
        rescue ArgumentError
          super
        end
      else
        super
      end
    end

    private

    def format
      options.fetch(:format)
    end

    def format?
      options.key?(:format)
    end

    def klass
      self.class.slug.to_s.camelize.constantize
    end

    def klasses
      [klass]
    end
  end
end
