# coding: utf-8

module ActiveInteraction
  # @private
  class AbstractDateTimeFilter < AbstractFilter
    def cast(value)
      case value
      when *klasses
        value
      when String
        begin
          if has_format?
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

    def has_format?
      options.key?(:format)
    end

    def klasses
      [klass]
    end
  end
end
