module ActiveInteraction
  class DateTimeFilter < Filter
    # @param value [Object]
    #
    # @return [DateTime]
    #
    # @raise (see Filter#cast)
    def cast(value)
      case value
      when DateTime
        value
      when String
        begin
          if has_format?
            DateTime.strptime(value, format)
          else
            DateTime.parse(value)
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
