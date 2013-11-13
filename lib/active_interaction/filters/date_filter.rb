module ActiveInteraction
  # @private
  class DateFilter < Filter
    def cast(value)
      case value
      when Date
        value
      when String
        begin
          if has_format?
            Date.strptime(value, format)
          else
            Date.parse(value)
          end
        rescue ArgumentError
          super
        end
      else
        super
      end
    end

    private

    def has_format?
      options.has_key?(:format)
    end

    def format
      options.fetch(:format)
    end
  end
end
