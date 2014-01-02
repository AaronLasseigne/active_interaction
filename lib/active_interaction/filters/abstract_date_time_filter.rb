# coding: utf-8

module ActiveInteraction
  # @private
  class AbstractDateTimeFilter < Filter
    def cast(value)
      case value
      when value_class
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
      fail NotImplementedError
    end

    def value_class
      klass
    end
  end
end
